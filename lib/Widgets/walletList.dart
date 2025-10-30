import 'package:expense_manager_app/Screen/walletScreen.dart';
import 'package:expense_manager_app/Widgets/editWallet.dart';
import 'package:expense_manager_app/Widgets/elevatedButtomCustom.dart';
import 'package:expense_manager_app/dataModel/walletModel.dart';
import 'package:expense_manager_app/database/DbSql.dart';
import 'package:expense_manager_app/database/DbSupabase.dart';
import 'package:expense_manager_app/navigator/pageRouter.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Walletlist extends StatefulWidget {
  const Walletlist({
    super.key,
    required this.walletListFuture,
    required this.getupdatedlist,
    required this.getupdateddata,
  });
  final Future<List<Walletmodel>> walletListFuture;
  final void Function() getupdatedlist;
  final void Function() getupdateddata;
  @override
  State<Walletlist> createState() => _WalletlistState();
}

class _WalletlistState extends State<Walletlist> {
  Widget showdetailsofwidget(String id, String pass) {
    return AlertDialog(
      shadowColor: const Color.fromARGB(255, 5, 46, 254),
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(60),
          bottomLeft: Radius.circular(60),
        ),
        side: const BorderSide(color: Color.fromARGB(255, 11, 43, 204)),
      ),
      title: const Text(
        "Wallet Details",
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(color: Colors.black, thickness: 2, height: 0),
            const SizedBox(height: 16),
            // Wallet ID
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color.fromARGB(49, 0, 0, 0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text("Wallet ID", style: TextStyle(fontSize: 18)),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: id));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Copied wallet id')),
                          );
                        },
                        icon: const Icon(Icons.copy_all_rounded),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.black, thickness: 2, height: 2),
                  const SizedBox(height: 8),
                  Text(id),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Password
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color.fromARGB(49, 0, 0, 0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Password", style: TextStyle(fontSize: 18)),
                  const Divider(color: Colors.black, thickness: 2, height: 2),
                  const SizedBox(height: 8),
                  Text(pass),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Shared with
            FutureBuilder<List<String>>(
              future: Dbsupabase().getSharedWalletUsers(id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(49, 0, 0, 0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Shared with", style: TextStyle(fontSize: 18)),
                        Divider(color: Colors.black, thickness: 2, height: 2),
                        SizedBox(height: 10),
                        Center(child: CircularProgressIndicator()),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(49, 0, 0, 0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Shared with",
                          style: TextStyle(fontSize: 18),
                        ),
                        const Divider(
                          color: Colors.black,
                          thickness: 2,
                          height: 2,
                        ),
                        const SizedBox(height: 10),
                        Text('Error: ${snapshot.error}'),
                      ],
                    ),
                  );
                }

                final sharedlist = snapshot.data ?? [];

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(49, 0, 0, 0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Shared with", style: TextStyle(fontSize: 18)),
                      const Divider(
                        color: Colors.black,
                        thickness: 2,
                        height: 2,
                      ),
                      const SizedBox(height: 8),
                      if (sharedlist.isEmpty)
                        const Text("No users")
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: sharedlist.map((person) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(47, 3, 3, 3),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(person),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Future<double> getFillPercentage(Walletmodel wallet) async {
    final total = await Dbsql().getTotalExpenseDb(wallet.walletId);
    if (wallet.Amount == 0) return 0.0;
    final percentage = total / wallet.Amount;
    return percentage.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final textsizer = MediaQuery.of(context).textScaler;
    return FutureBuilder(
      future: widget.walletListFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Center(child: Text("Error: ${snapshot.error}")),
          );
        }

        final walletData = snapshot.data;
        if (walletData == null || walletData.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: Text(
                "No wallets found",
                textScaler: textsizer,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final wallet = walletData[index];

            return FutureBuilder<double>(
              future: getFillPercentage(wallet),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const SizedBox(
                    height: 80,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }

                final percentagetofill = snap.data!;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Dismissible(
                    key: Key(wallet.walletId),

                    onDismissed: (_) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          shadowColor: const Color.fromARGB(255, 5, 46, 254),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.only(
                              topRight: Radius.circular(60),
                              bottomLeft: Radius.circular(60),
                            ),
                            side: BorderSide(
                              color: const Color.fromARGB(255, 11, 43, 204),
                            ),
                          ),
                          title: Text(
                            "Comfirm",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              color: const Color.fromARGB(255, 1, 27, 173),
                            ),
                          ),
                          content: Divider(
                            color: Colors.black,
                            thickness: 3,
                            height: 2,
                          ),

                          actions: [
                            ElevatedButton.icon(
                              label: Text("Delete"),

                              onPressed: () async {
                                await Dbsql().deletewallet(wallet.walletId);
                                await Dbsupabase().deleteWalletClound(
                                  wallet.walletId,
                                );
                                await Dbsql().deleteExpenses(wallet.walletId);
                                await Dbsupabase()
                                    .deleteallexpensesformwalletClound(
                                      wallet.walletId,
                                    );
                                setState(() {
                                  walletData.removeAt(index);
                                });
                                widget.getupdatedlist();
                                widget.getupdateddata();
                                Navigator.of(context).pop();
                              },
                              icon: Icon(Icons.delete_forever),
                            ),
                            ElevatedButton.icon(
                              label: Text("Cancel"),
                              onPressed: () async {
                                widget.getupdatedlist();
                                Navigator.of(context).pop();
                              },
                              icon: Icon(Icons.delete_forever),
                            ),
                          ],
                        ),
                      );
                    },
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          PageRouter(
                            updatedata: widget.getupdateddata,
                            updatewalletlist: widget.getupdatedlist,
                          ).routeToInsideWallet(wallet),
                        );
                      },
                      onLongPress: () {
                        if (wallet.type == walletType.public) {
                          showDialog(
                            context: context,
                            builder: (context) => showdetailsofwidget(
                              wallet.walletId,
                              wallet.password ?? "",
                            ),
                          );
                        }
                      },
                      child: Stack(
                        children: [
                          // Background progress fill
                          Container(
                            height: MediaQuery.of(context).size.height * .13,
                            width:
                                MediaQuery.of(context).size.width *
                                percentagetofill,
                            decoration: BoxDecoration(
                              gradient: percentagetofill < 1
                                  ? const LinearGradient(
                                      colors: [
                                        Color.fromARGB(255, 16, 83, 254),
                                        Color.fromARGB(138, 16, 75, 254),
                                      ],
                                    )
                                  : const LinearGradient(
                                      colors: [
                                        Color.fromARGB(255, 248, 0, 0),
                                        Color.fromARGB(120, 255, 0, 0),
                                      ],
                                    ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          // Foreground card
                          Container(
                            height: MediaQuery.of(context).size.height * .13,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: percentagetofill > 0
                                  ? Colors.transparent
                                  : Colors.black.withOpacity(0.1),
                              border: Border.all(width: 1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Text(
                                                  wallet.WalletName,
                                                  textScaler: textsizer,
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: percentagetofill > 0
                                                        ? Colors.black
                                                        : Colors.white,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                PopupMenuButton(
                                                  icon: Icon(
                                                    Icons
                                                        .arrow_drop_down_outlined,
                                                    color: percentagetofill > 0
                                                        ? Colors.black
                                                        : Colors.white,
                                                  ),
                                                  shadowColor:
                                                      Colors.transparent,
                                                  color: Colors.white,
                                                  itemBuilder: (context) {
                                                    return [
                                                      PopupMenuItem(
                                                        child: ElevatedButton(
                                                          onPressed: () {
                                                            showDialog(
                                                              context: context,
                                                              builder: (context) {
                                                                return Editwallet(
                                                                  getupdateddata:
                                                                      widget
                                                                          .getupdateddata,
                                                                  getupdatedlist:
                                                                      widget
                                                                          .getupdatedlist,
                                                                  editingWallet:
                                                                      wallet,
                                                                );
                                                              },
                                                            );
                                                          },
                                                          child: Text(
                                                            "Edit",
                                                            textScaler:
                                                                textsizer,
                                                          ),
                                                        ),
                                                      ),
                                                    ];
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Row(
                                      children: [
                                        Text(
                                          "₹",
                                          textScaler: textsizer,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Color.fromARGB(
                                              255,
                                              0,
                                              126,
                                              70,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "${wallet.Amount}",
                                          textScaler: textsizer,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      wallet.type == walletType.private
                                          ? "Private"
                                          : "Public",
                                      textScaler: textsizer,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }, childCount: walletData.length),
        );
      },
    );
  }
}
