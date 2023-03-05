import 'package:flutter/material.dart';
import 'package:project_note/globals/globals.dart';

Widget connectionAlert(BuildContext context) {
  return SizedBox(
    height: screenHeight / 3,
    child: Card(
      color: Colors.black,
      margin: const EdgeInsets.all(12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  padding: const EdgeInsets.all(0.0),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.cancel_rounded,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
              ],
            ),
            const Text('Device Connected',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                )),
            ClipRRect(
              borderRadius: BorderRadius.circular(20), // Image border
              child: Image.asset('assets/connection.jpg',
                  width: MediaQuery.of(context).size.width * 0.25,
                  height: MediaQuery.of(context).size.width * 0.25,
                  fit: BoxFit.cover),
            ),
            const Text('You are connected to the internet',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                )),
          ],
        ),
      ),
    ),
  );
}

Widget noConnectionAlert(BuildContext context) {
    return SizedBox(
      height: screenHeight / 3,
      child: Card(
        color: Colors.black,
        margin: const EdgeInsets.all(12.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    padding: const EdgeInsets.all(0.0),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.cancel_rounded,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                ],
              ),
              const Text('No Connection',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  )),
              ClipRRect(
                borderRadius: BorderRadius.circular(20), // Image border
                child: Image.asset('assets/no_connection.jpg',
                    width: MediaQuery.of(context).size.width * 0.25,
                    height: MediaQuery.of(context).size.width * 0.25,
                    fit: BoxFit.cover),
              ),
              const Text(
                  '*Make sure to connect to internet to save your changes',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  )),
            ],
          ),
        ),
      ),
    );
  }
