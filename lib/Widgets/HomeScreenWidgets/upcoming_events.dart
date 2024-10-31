import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ippu/Util/app_endpoints.dart';

class UpcomingEventsWidget extends StatelessWidget {
  final List<dynamic> upcomingEvents;
  final bool profileStatus;
  final Function(String) showBottomNotification;
  final VoidCallback navigateToEventsScreen;

  const UpcomingEventsWidget({
    super.key,
    required this.upcomingEvents,
    required this.profileStatus,
    required this.showBottomNotification,
    required this.navigateToEventsScreen,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final formatter = NumberFormat("#,##0", "en_US");

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, size),
          SizedBox(height: size.height * 0.005),
          upcomingEvents.isNotEmpty
              ? _buildEventsList(context, size, formatter)
              : _buildNoEventsMessage(size),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Size size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Upcoming Events',
          style: GoogleFonts.lato(
            fontSize: size.height * 0.02,
            fontWeight: FontWeight.bold,
            color: Colors.blue[600],
          ),
        ),
        TextButton(
          onPressed: () {
            if (profileStatus) {
              showBottomNotification('Please complete your profile first!');
            } else {
              navigateToEventsScreen();
            }
          },
          child: Text(
            'View More',
            style: GoogleFonts.lato(
              fontSize: size.height * 0.013,
              color: Colors.blue[600],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventsList(
      BuildContext context, Size size, NumberFormat formatter) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: upcomingEvents.length > 3 ? 3 : upcomingEvents.length,
      separatorBuilder: (context, index) =>
          SizedBox(height: size.height * 0.02),
      itemBuilder: (context, index) =>
          _buildEventCard(context, size, upcomingEvents[index], formatter),
    );
  }

  Widget _buildEventCard(BuildContext context, Size size,
      Map<String, dynamic> event, NumberFormat formatter) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEventBanner(size, event),
          Padding(
            padding: EdgeInsets.all(size.width * 0.03),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEventTitle(context, size, event),
                SizedBox(height: size.height * 0.01),
                _buildEventDetails(context, size, event, formatter),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventBanner(Size size, Map<String, dynamic> event) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: Image.network(
            '${AppEndpoints.baseImageUrl}/banners/${event['banner_name']}',
            height: size.height * 0.12,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: size.height * 0.12,
              color: Colors.grey[300],
              child: Icon(Icons.image_not_supported,
                  color: Colors.grey[600], size: size.height * 0.05),
            ),
          ),
        ),
        Positioned(
          top: size.height * 0.01,
          right: size.width * 0.02,
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.02, vertical: size.height * 0.005),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              '${event['points']} points',
              style: GoogleFonts.lato(
                  fontSize: size.height * 0.014,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventTitle(
      BuildContext context, Size size, Map<String, dynamic> event) {
    return Text(
      event['name'],
      style: GoogleFonts.lato(
        fontSize: size.height * 0.018,
        fontWeight: FontWeight.bold,
        color: Colors.blue[600],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildEventDetails(BuildContext context, Size size,
      Map<String, dynamic> event, NumberFormat formatter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow(
            context,
            size,
            Icons.calendar_today,
            DateFormat('MMM dd, yyyy')
                .format(DateTime.parse(event['start_date']))),
        SizedBox(height: size.height * 0.005),
        _buildDetailRow(context, size, Icons.attach_money,
            'UGX. ${formatter.format(double.parse(event['rate']))}'),
        if (event['location'] != null) ...[
          SizedBox(height: size.height * 0.005),
          _buildDetailRow(context, size, Icons.location_on, event['location'],
              maxLines: 1),
        ],
      ],
    );
  }

  Widget _buildDetailRow(
      BuildContext context, Size size, IconData icon, String text,
      {int maxLines = 2}) {
    return Row(
      children: [
        Icon(
          icon,
          size: size.height * 0.015,
          color: Colors.blue[600],
        ),
        SizedBox(width: size.width * 0.01),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.lato(
              fontSize: size.height * 0.015,
              color: Colors.blue[600],
            ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildNoEventsMessage(Size size) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white, // Changed to make the card white
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.04),
        child: Center(
          child: Text(
            'No upcoming events',
            style: GoogleFonts.lato(
                fontSize: size.height * 0.018, color: Colors.blue[600]),
          ),
        ),
      ),
    );
  }
}
