# ExpensifyX

A new Flutter project.

# DESCRIPTION

Purpose: A cross-platform Flutter expense manager app that tracks wallets and expenses locally (SQLite) and syncs with Supabase cloud storage. Core flows: create wallets, add/edit/delete expenses, view totals and progress, and optionally share/access public wallets.
Key features:

Local persistent storage with sync logic: Dbsql handles SQLite DB operations (open/create DB, CRUD for wallets & expenses, totals, sync helpers) — see DbSql.dart.
Cloud sync and storage: Dbsupabase integrates Supabase (authentication, cloud tables, storage for images) — see DbSupabase.dart.
Data models: Walletmodel and Expensemodel represent wallets and expenses — see walletModel.dart and expensemodel.dart.
UI screens:
App entry: main.dart
Home: homeScreen shows wallets and overview — see homeScreen.dart.
Wallet details: Walletscreen displays a wallet, its expenses and totals — see walletScreen.dart.
Reusable widgets:
Wallet list: Walletlist — see walletList.dart.
Expense list: Expenselist — see expenselist.dart.
Total/summary bar: Totalexpense — see totalexpense.dart.
Add/Edit flows: add/edit wallet and expense widgets (lib/Widgets/addwallet.dart, addExpense.dart, editWallet.dart, lib/Widgets/editexpense.dart).
Authentication UI: signup widget — see signupWidget.dart.
Architecture & behavior highlights:

Local-first design: data lives in SQLite via Dbsql.opendb() and is read/updated frequently; cloud sync via Dbsupabase keeps remote copy and image storage in Supabase.
Sync logic merges cloud and local records (add missing cloud items locally, remove local items not in cloud) — implemented in DbSql.dart.
Images: uploaded to Supabase storage and fetched back into local app files — see image upload/download in DbSupabase.dart.
UI uses SliverAppBar + CustomScrollView for responsive screens (see walletScreen.dart and lib/Screen/homeScreen.dart).
Where to look first:

App bootstrap & Supabase init: main.dart
Local DB and sync: DbSql.dart
Cloud integration & storage: DbSupabase.dart
Wallet and expense UI: homeScreen.dart, walletScreen.dart, expenselist.dart, totalexpense.dart
If you want, I can produce a README-ready project summary or a shorter app-store style blurb.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
