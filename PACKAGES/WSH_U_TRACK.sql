--------------------------------------------------------
--  DDL for Package WSH_U_TRACK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_U_TRACK" AUTHID CURRENT_USER AS
/* $Header: WSHUTRKS.pls 115.7 2002/11/12 02:03:18 nparikh ship $ */

TYPE EnhancedTrackInRec IS RECORD (
				InquiryNumber				VARCHAR2(35),
				TypeOfInquiryNumber		VARCHAR2(1),
				InternalKey					VARCHAR2(120),
				SenderShipperNumber		VARCHAR2(10),
				FromPickupDate				DATE,
				ToPickupDate				DATE,
				DestinationPostalCode	VARCHAR2(16),
				DestinationCountry		VARCHAR2(3));

TYPE TrackHeaderRec IS RECORD (
				UPSOnLine					VARCHAR2(9),
				AppVersion					NUMBER,
				TypeofResponse				VARCHAR2(1),
				InquiryNumber				VARCHAR2(35),
				TypeOfInquiryNumber		VARCHAR2(1),
				SenderShiperNumber		VARCHAR2(10),
				InternalKey					VARCHAR2(120),
				FromPickupDate				DATE,
				ToPickupDate				DATE,
				DestinationPostalCode	VARCHAR2(11),
				DestinationCountry		VARCHAR2(3));

TYPE TrackErrorRec IS RECORD(
				UPSOnLine					VARCHAR2(9),
				AppVersion					NUMBER,
				ReturnCode					NUMBER,
				MessageNumber				VARCHAR2(4),
				MessageText					VARCHAR2(500));

TYPE TrackAddress IS RECORD(
				UPSOnLine					VARCHAR2(9),
				AppVersion					NUMBER,
				TypeOfAddress				VARCHAR2(1),
				Name							VARCHAR2(50),
				Address1						VARCHAR2(100),
				Address2						VARCHAR2(100),
				Address3						VARCHAR2(100),
				City							VARCHAR2(30),
				StateProv					VARCHAR2(5),
				PostalCode					VARCHAR2(16),
				Country						VARCHAR2(3));

TYPE TrackAddressTblTyp IS TABLE OF TrackAddress
				INDEX BY BINARY_INTEGER;


TYPE MultiSumHdrRec IS RECORD (
				UPSOnLine						VARCHAR2(9),
				AppVersion						NUMBER,
				InternalShipmentKey			VARCHAR2(120),
				ServiceLevelDescription		VARCHAR2(70),
				PickupDate						DATE,
				ScheduledDeliveryDate		DATE,
				TotalShipmentWeight			NUMBER(19,2),
				WeightUOM						VARCHAR2(3),
				NumberOfPackagesInShipment NUMBER,
				NumberOfPackagesDelivered	NUMBER,
				NumberOfPackagesActive		NUMBER,
				ConsigneeAddressIndex		NUMBER,
				MPieceSummaryDtlIndex		NUMBER);

TYPE MultiSumHdrTblTyp IS TABLE OF MultiSumHdrRec
				INDEX BY BINARY_INTEGER;


TYPE MultiSumDtlRec IS RECORD (
				UPSOnLine					VARCHAR2(9),
				AppVersion					NUMBER,
				TrackingNumber				VARCHAR2(35),
				InternalPackageKey		VARCHAR2(120),
				ActivityDetailIndex		NUMBER);


TYPE MultiSumDtlTblTyp IS TABLE OF MultiSumDtlRec
				INDEX BY BINARY_INTEGER;


TYPE PkgDtlSegRec IS RECORD (
				UPSOnLine							VARCHAR2(9),
				AppVersion							NUMBER,
				TrackingNumber						VARCHAR2(35),
				InternalPackageKey				VARCHAR2(120),
				ShipmentNumber						VARCHAR2(35),
				InternalShipmentKey				VARCHAR2(85),
				PickupDate							DATE,
				NumberOfPackagesInShipment		NUMBER,
				ServiceLevelDescription			VARCHAR2(35),
				PackageWeight						NUMBER(10,2),
				WeightUOM							VARCHAR2(3),
				SignedForByName					VARCHAR2(15),
				Location								VARCHAR2(15),
				CusotmerReferenceNumber			VARCHAR2(35),
				ConsigneeAddressIndex			NUMBER,
				ActivityDetailIndex				NUMBER);
				/* Row Id for the corresponding row in the Activity Detail Table */

TYPE PkgDtlSegTblTyp IS TABLE OF PkgDtlSegRec
				INDEX BY BINARY_INTEGER;


TYPE PkgProgressHdrRec IS RECORD (
				UPSOnLine							VARCHAR2(9),
				AppVersion							NUMBER,
				NumberOfActivityDetailLines	VARCHAR2(4),
				ActivityDetailIndex				NUMBER);
				/* Row Id for the corresponding row in the Activity Detail Table */


TYPE ActivityDtlSegment IS RECORD (
				UPSOnLine						VARCHAR2(9),
				AppVersion						NUMBER,
				StatusType						VARCHAR2(1),
				StatusLongDescription		VARCHAR2(140),
				ActivityDate					DATE, /*YYYYMMDD HH24:MI:SS*/
				-- ActivityTime				VARCHAR2(6),
				ActivityAddressIndex		BINARY_INTEGER);
				/* Pointer to the Address Record in the Address Table.*/

TYPE ActivityDetailTblTyp IS TABLE OF ActivityDtlSegment
				INDEX BY BINARY_INTEGER;

PROCEDURE EnhancedTracking(
				p_api_version            IN   NUMBER,
				p_init_msg_list          IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
				x_return_status         OUT NOCOPY    VARCHAR2,
				x_msg_count             OUT NOCOPY    NUMBER,
				x_msg_data              OUT NOCOPY    VARCHAR2,
				p_AppVersion				 IN	VARCHAR2,
				p_AcceptLicenseAgreement IN   VARCHAR2,
				p_ResponseType				 IN	VARCHAR2,
				p_request_in				 IN	EnhancedTrackInRec,
				x_track_header				OUT NOCOPY 	TrackHeaderRec,
				x_track_error				OUT NOCOPY 	TrackErrorRec,
				x_track_address			OUT NOCOPY 	TrackAddressTblTyp,
				x_multi_sum_header		OUT NOCOPY 	MultiSumHdrTblTyp,
				x_multi_sum_detail		OUT NOCOPY 	MultiSumDtlTblTyp,
				x_pkg_detail_segment		OUT NOCOPY 	PkgDtlSegTblTyp,
				x_pkg_progress				OUT NOCOPY 	PkgProgressHdrRec,
				x_activity_detail			OUT NOCOPY 	ActivityDetailTblTyp);

END WSH_U_TRACK;

 

/
