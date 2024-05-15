import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/crypto_model.dart';

class DetailsPage extends StatefulWidget {
  CryptoModel crypto;
  int duration;

  DetailsPage({required this.duration, required this.crypto, super.key});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  List<FlSpot> historicData = [];
  int selectedIndex = 0;

  final List<Map<String, dynamic>> chartDuration = [
    {'label': '12 Months', 'days': 365},
    {'label': '6 Months', 'days': 180},
    {'label': '1 Months', 'days': 30},
    {'label': '24 Hours', 'days': 1},
  ];

  Future<void> getCryptoApi(int duration) async {
    final String apiUrl =
        "https://api.coingecko.com/api/v3/coins/${widget.crypto.id}/market_chart?vs_currency=usd&days=$duration&interval=daily&precision=0";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> responseData =
        jsonDecode(response.body.toString())['prices'];

        setState(() {
          historicData = responseData
              .map((e) =>
              FlSpot(responseData.indexOf(e).toDouble(), e[1].toDouble()))
              .toList();
        });
      } else {}
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCryptoApi(widget.duration);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.crypto.name),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CachedNetworkImage(
            height: 80,
            width: 80,
            imageUrl: widget.crypto.image,
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            widget.crypto.name,
            style: TextStyle(
                color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            "Current price: ${widget.crypto.currentPrice}",
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.3,
            child: LineChart(LineChartData(
                lineBarsData: [
                  LineChartBarData(
                      spots: historicData,
                      isCurved: false,
                      color: Colors.black,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: true))
                ],
                titlesData: FlTitlesData(
                    show: false,
                    leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                            reservedSize: 50,
                            showTitles: true,
                            interval: 100000)),
                    rightTitles: AxisTitles(
                        sideTitles:
                        SideTitles(reservedSize: 44, showTitles: false)),
                    topTitles: AxisTitles(
                        sideTitles:
                        SideTitles(reservedSize: 44, showTitles: false)),
                    bottomTitles: AxisTitles(
                        sideTitles:
                        SideTitles(reservedSize: 44, showTitles: false))),
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: false))),
          ),
          SizedBox(
            height: 30,
          ),
          Container(
            padding: EdgeInsets.all(16),
            height: 80,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (int i = 0; i < chartDuration.length; i++)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                    child: ElevatedButton(
                      onPressed: () {

                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue),
                      child: Text(
                        chartDuration[i]['label'],
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
              ],
            ),
          )
        ],
      ),
    );
  }
}