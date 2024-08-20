import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:user_app/models/invoice.dart';

Future<void> sendInvoiceByEmail(Invoice invoice) async {
  final String apiKey =
      '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';
  final String sendGridUrl = 'https://api.sendgrid.com/v3/mail/send';

  final emailContent = '''
    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 10px; background-color: #f9f9f9;">
        <h1 style="text-align: center; color: #d9534f;">تفاصيل الفاتورة</h1>
        <p><strong>رقم الفاتورة:</strong> ${invoice.invoiceId}</p>
        <p><strong>رقم الطلب:</strong> ${invoice.orderId}</p>
        <p><strong>المبلغ الكلي:</strong> <span style="color: #5cb85c; font-size: 1.2em;">${invoice.totalPrice}</span></p>
        <p><strong>تكلفة التوصيل:</strong> ${invoice.deliveryCost}</p>
        <p><strong>وقت الطلب:</strong> ${invoice.timestamp}</p>
        <hr style="border: 1px solid #d9534f;">
        <h2 style="color: #d9534f;">العناصر:</h2>
        <ul style="list-style-type: none; padding: 0;">
            ${invoice.items.map((item) => '''
                <li style="padding: 10px 0; border-bottom: 1px solid #e0e0e0;">
                    <strong>${item.meal.name}</strong> x ${item.quantity}
                </li>''').join()}
        </ul>
        <hr style="border: 1px solid #d9534f;">
        <p style="text-align: center; font-size: 0.9em; color: #888;">شكراً لطلبك! نتمنى لك يوماً سعيداً.</p>
    </div>
''';

  final emailData = {
    'personalizations': [
      {
        'to': [
          {'email': invoice.userEmail}
        ],
        'subject': 'فاتورتك من تطبيق سريع',
      }
    ],
    'from': {'email': 'sariecompany@gmail.com'},
    'content': [
      {
        'type': 'text/html',
        'value': emailContent,
      }
    ]
  };

  final response = await http.post(
    Uri.parse(sendGridUrl),
    headers: {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(emailData),
  );

  if (response.statusCode == 202) {
    print('Invoice sent successfully to ${invoice.userEmail}');
  } else {
    print('Failed to send invoice. Status code: ${response.statusCode}');
  }
}
