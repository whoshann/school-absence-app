// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../../constans/presence_calender_constants.dart';

// class AttendanceLegend extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: EdgeInsets.symmetric(horizontal: 16),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Keterangan:',
//               style: GoogleFonts.plusJakartaSans(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 12),
//             Wrap(
//               spacing: 16,
//               runSpacing: 8,
//               children: AttendanceConstants.statusLabels.entries.map((entry) {
//                 return _buildLegendItem(
//                   entry.value,
//                   AttendanceConstants.statusColors[entry.key]!,
//                 );
//               }).toList(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLegendItem(String label, Color color) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Container(
//           width: 16,
//           height: 16,
//           decoration: BoxDecoration(
//             color: color,
//             shape: BoxShape.circle,
//           ),
//         ),
//         SizedBox(width: 8),
//         Text(
//           label,
//           style: GoogleFonts.plusJakartaSans(fontSize: 14),
//         ),
//       ],
//     );
//   }
// }