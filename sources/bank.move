module bank::asset_bank {
    use sui::balance::{Balance};
    use sui::coin::{Coin, value, join};
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::event;
    use sui::table;
    use sui::table::Table;
    use sui::vec_set;
    use sui::vec_set::VecSet;

    /// **Asset Bank Object**
    public struct Bank<phantom T> has key, store {
        id: UID,
        total_deposits: u64,
        active_receipts: u64,
        sui_balance: Balance<sui::sui::SUI>,
        other_balances: VecSet<Coin<T>>,
    }

    /// **Receipt NFT (Non-Transferable)**
    public struct Receipt has key, store, drop {
        id: UID,
        number: u64,
        depositor: address,
        amount: u64,
    }

    /// **Deposit Event**
    public struct DepositEvent has copy, drop {
        depositor: address,
        amount: u64,
        asset_type: u8,
    }

    /// **Withdrawal Event**
    public struct WithdrawEvent has copy, drop {
        withdrawer: address,
        amount: u64,
        asset_type: u8,
    }

    /// **Initialize the Bank**
    public fun init<T>(ctx: &mut TxContext): Bank<T> {
        Bank {
            id: object::new(ctx),
            total_deposits: 0,
            active_receipts: 0,
            sui_balance: balance::zero(),
            other_balances: table::empty(),
        }
    }

    // Error Codes:
    //  1 -> Deposit amount must be greater than zero
    //  2 -> Unauthorized withdrawal
    //  3 -> Insufficient balance

    /// **Deposit Funds & Get NFT Receipt**
    public fun deposit<T>(bank: &mut Bank<T>, coin: Coin<T>, ctx: &mut TxContext): Receipt {
        let amount = value(&coin);
        assert!(amount > 0, 1);

        // Handle deposit for SUI or other tokens
        if (is_sui::<T>()) {
            balance::join(&mut bank.sui_balance, coin_balance);
        } else {
            if (!bank.other_balances.contains(coin)) {
                bank.other_balances.insert(coin);
            };
            // let current_balance = vec_set::borrow_mut(&mut bank.other_balances);
            // *current_balance = *current_balance + amount;
        };

        // Update counters
        bank.total_deposits = bank.total_deposits + 1;
        bank.active_receipts = bank.active_receipts + 1;

        // Mint NFT Receipt
        let receipt = Receipt {
            id: object::new(ctx),
            number: bank.total_deposits,
            depositor: tx_context::sender(ctx),
            amount,
        };

        // Emit Deposit Event
        event::emit(DepositEvent {
            depositor: receipt.depositor,
            amount,
            asset_type: 0
        });

        // Transfer NFT receipt to user (Non-transferable)
        transfer::share_object(receipt);

        receipt
    }

    /// **Redeem Funds by Returning NFT**
    public fun redeem<T>(bank: &mut Bank<T>, receipt: Receipt, ctx: &mut TxContext): Coin<T> {
        let amount = receipt.amount;


        let depositor = receipt.depositor;
        assert!(tx_context::sender(ctx) == depositor, 2);

        // Deduct balance and refund coin
        let refund_coin;
        if (is_sui::<T>()) {
            assert!(balance::value(&bank.sui_balance) >= amount, 3);
            refund_coin = balance::split(&mut bank.sui_balance, amount);
        } else {
            // Handle non-SUI token withdrawal
            assert!(bank.other_balances.contains(amount), 3);
            let current_balance = table::borrow_mut(&mut bank.other_balances, amount);
            assert!(*current_balance >= amount, 3);

            // Deduct balance
            *current_balance = *current_balance - amount;
            refund_coin = balance::split(&mut balance::from(amount), amount);

            // Remove entry if balance becomes 0
            if (*current_balance == 0) {
                bank.other_balances.remove(amount);
            }
        };

        // Decrease active receipts counter
        bank.active_receipts = bank.active_receipts - 1;

        // Emit Withdrawal Event
        event::emit(WithdrawEvent {
            withdrawer: depositor,
            amount,
            asset_type: 0,
        });

        // Destroy the receipt NFT
        object::delete(receipt);

        refund_coin
    }
}
