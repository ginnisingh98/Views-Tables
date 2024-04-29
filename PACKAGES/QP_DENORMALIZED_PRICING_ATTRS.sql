--------------------------------------------------------
--  DDL for Package QP_DENORMALIZED_PRICING_ATTRS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_DENORMALIZED_PRICING_ATTRS" AUTHID CURRENT_USER AS
/* $Header: QPXDNPAS.pls 120.0.12010000.3 2008/08/19 11:41:08 smbalara ship $ */

/* Added for bug 7309559 */
TYPE Num_Type IS TABLE OF Number INDEX BY BINARY_INTEGER;
G_PERF CONSTANT VARCHAR2(30)  := 'QP_PERFORMANCE_CONTROL';
G_ON CONSTANT VARCHAR2(30)  := 'ON';
G_OFF CONSTANT VARCHAR2(30)  := 'OFF';
G_REQUEST CONSTANT VARCHAR2(30)  := 'INT';
G_UPDATE_FACTOR CONSTANT VARCHAR2(30)  := 'FACTOR';

PROCEDURE Prepare_input_data(
	ERR_BUFF OUT  NOCOPY VARCHAR2,
	RETCODE OUT  NOCOPY NUMBER,
	P_LIST_HEADER_ID_LOW IN OUT NOCOPY NUMBER,
	P_LIST_HEADER_ID_HIGH IN OUT NOCOPY NUMBER,
	P_LIST_HEADER_ID_TBL IN OUT NOCOPY NUM_TYPE,
	P_UPDATE_TYPE IN VARCHAR2
);

PROCEDURE Update_search_ind(
	ERR_BUFF OUT  NOCOPY VARCHAR2,
	RETCODE OUT  NOCOPY NUMBER,
	P_LIST_HEADER_ID_LOW IN NUMBER,
	P_LIST_HEADER_ID_HIGH IN NUMBER,
	P_LIST_HEADER_ID_TBL IN NUM_TYPE,
	P_UPDATE_TYPE IN VARCHAR2 DEFAULT 'BATCH'
  );

PROCEDURE Update_search_ind(
	ERR_BUFF OUT NOCOPY VARCHAR2,
	RETCODE OUT NOCOPY NUMBER,
	P_LIST_HEADER_ID_LOW IN NUMBER,
	P_LIST_HEADER_ID_HIGH IN NUMBER,
	P_UPDATE_TYPE IN VARCHAR2
  );
/* End for bug 7309559 */
  PROCEDURE Update_Pricing_Attributes(
                             p_list_header_id_low  IN NUMBER default null,
                             p_list_header_id_high IN NUMBER default null,
                             p_update_type         IN VARCHAR2 default 'BATCH');

  PROCEDURE Populate_Factor_List_Attrs(
                              p_list_header_id_low  IN NUMBER default null,
                              p_list_header_id_high IN NUMBER default null);

END QP_Denormalized_Pricing_Attrs;

/
