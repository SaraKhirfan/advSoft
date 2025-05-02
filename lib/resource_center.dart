import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourceCenter extends StatelessWidget {
  const ResourceCenter({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resource Center', style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Financial Tools & Calculators'),
              const SizedBox(height: 8),
              _buildResourceList([
                ResourceItem(
                  title: 'Investment Calculator',
                  description: 'Calculate potential returns on your investments over time',
                  icon: Icons.trending_up,
                  url: 'https://www.calculator.net/investment-calculator.html?ctype=endamount&ctargetamountv=1%2C000%2C000&cstartingprinciplev=1%2C000&cyearsv=39&cinterestratev=10&ccompound=annually&ccontributeamountv=200&cadditionat1=end&ciadditionat1=monthly&printit=0&x=Calculate#calresult',
                ),
                ResourceItem(
                  title: 'Loan Calculator',
                  description: 'Calculate monthly payments and total interest for loans',
                  icon: Icons.money,
                  url: 'https://www.calculator.net/loan-calculator.html',
                ),
                ResourceItem(
                  title: 'Retirement Calculator',
                  description: 'Plan your retirement savings and future income',
                  icon: Icons.beach_access,
                  url: 'https://www.calculator.net/retirement-calculator.html',
                ),
                ResourceItem(
                  title: 'Budget Calculator',
                  description: 'Create a balanced budget based on your income',
                  icon: Icons.account_balance_wallet,
                  url: 'https://www.calculator.net/budget-calculator.html',
                ),
              ]),

              const SizedBox(height: 24),
              _buildSectionHeader('Budgeting Methods & Rules'),
              const SizedBox(height: 8),
              _buildResourceList([
                ResourceItem(
                  title: '50/30/20 Rule',
                  description: 'Learn about allocating 50% to needs, 30% to wants, and 20% to savings',
                  icon: Icons.pie_chart,
                  url: 'https://www.investopedia.com/ask/answers/022916/what-502030-budget-rule.asp',
                ),
                ResourceItem(
                  title: '70/20/10 Rule',
                  description: 'Discover the 30% needs, 30% wants, 30% savings, and 10% giving approach to budgeting',
                  icon: Icons.donut_large,
                  url: 'https://hyperjar.com/blog/the-70-20-10-rule#:~:text=Applying%20around%2070%25%20of%20your,HyperJar%20CEO%20Mat%20Megens%20says.',
                ),
                ResourceItem(
                  title: '30/30/30/10 Rule',
                  description: 'Discover the 30% needs, 30% wants, 30% savings, and 10% giving approach to budgeting',
                  icon: Icons.insert_chart,
                  url: 'https://www.kotak.com/en/stories-in-focus/accounts-deposits/savings-account/all-about-the-30-30-30-10-rule-and-how-it-can-work-wonders-for-your-savings.html',
                ),
                ResourceItem(
                  title: 'Envelope System',
                  description: 'Physically separate cash for different spending categories',
                  icon: Icons.mail_outline,
                  url: 'https://www.ramseysolutions.com/budgeting/envelope-system-explained',
                ),
              ]),

              const SizedBox(height: 24),

              _buildSectionHeader('Helpful Apps & Tools'),
              const SizedBox(height: 8),
              _buildResourceList([
                ResourceItem(
                  title: 'Investment Platforms',
                  description: 'Review beginner-friendly investment platforms',
                  icon: Icons.show_chart,
                  url: 'https://www.nerdwallet.com/best/investing/investment-apps',
                ),
                ResourceItem(
                  title: 'Retirement Planning Tools',
                  description: 'Resources for planning your retirement',
                  icon: Icons.elderly,
                  url: 'https://www.usa.gov/retirement-planning-tools',
                ),
              ]),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.category, color: Colors.deepPurple),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceList(List<ResourceItem> items) {
    return SizedBox(
      height: 220, // Fixed height for the horizontal list
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Container(
            width: 250, // Increased width from 200 to 280 pixels
            margin: const EdgeInsets.only(right: 12),
            child: _buildResourceCard(context, items[index]),
          );
        },
      ),
    );
  }

  Widget _buildResourceCard(BuildContext context, ResourceItem item) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _launchUrl(item.url),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.icon,
                  size: 32,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  item.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap to open',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResourceItem {
  final String title;
  final String description;
  final IconData icon;
  final String url;

  ResourceItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.url,
  });
}