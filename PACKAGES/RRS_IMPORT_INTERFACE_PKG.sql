--------------------------------------------------------
--  DDL for Package RRS_IMPORT_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RRS_IMPORT_INTERFACE_PKG" AUTHID DEFINER  as
/* $Header: RRSIMINS.pls 120.0.12010000.6 2010/02/05 03:53:44 sunarang noship $ */

Procedure main(
ERRBUF                          OUT NOCOPY VARCHAR2
,RETCODE                         OUT NOCOPY VARCHAR2
,p_batch_id                      IN              number
,p_purge_rows                IN              varchar2
,p_gather_stats                IN              varchar2
);

Procedure check_prereqs(
p_batch_id                      IN              number
,x_return_status                OUT NOCOPY      varchar2
);

Procedure Check_site_status_code(
 p_site_id_num                  IN              varchar2
,p_site_status_code             IN              varchar2
,x_return_flag                  OUT NOCOPY      varchar2
);

Procedure Check_site_id_num(
 p_site_id_num                  IN              varchar2
,p_site_id                      IN              varchar2
,p_transaction_type             IN              varchar2
,x_return_flag                  OUT NOCOPY      varchar2
);

Procedure validate_new_rows(
p_batch_id                      IN              number
,p_purge_rows                IN              varchar2
,x_return_flag                  OUT NOCOPY      varchar2
);

Procedure Validate_update_rows(
p_batch_id                      IN              number
,p_purge_rows                IN              varchar2
,x_return_flag                  OUT NOCOPY      varchar2
);



Procedure Check_site_type_code(
 p_site_id_num                  IN              varchar2
,p_site_type_code               IN              varchar2
,x_return_flag                  OUT NOCOPY      varchar2
);

Procedure Check_site_party_id(
p_site_id_num                   IN              varchar2
,p_site_party_id                IN              number
,x_return_flag                  OUT NOCOPY      varchar2
);

Procedure Check_le_party_id(
p_site_id_num                   IN              varchar2
,p_le_party_id                	IN              number
,x_return_flag                  OUT NOCOPY      varchar2
);

Procedure Check_site_brand_code(
 p_site_id_num                  IN              varchar2
,p_site_brand_code              IN              varchar2
,x_return_flag                  OUT NOCOPY      varchar2
);

Procedure Check_site_calendar_code(
 p_site_id_num                  IN              varchar2
,p_site_calendar_code           IN              varchar2
,x_return_flag                  OUT NOCOPY      varchar2
);

Procedure Check_site_use_type_code(
p_site_id_num                   IN              varchar2
,p_site_use_type_code           IN              varchar2
,x_return_flag                  OUT NOCOPY      varchar2
);

Procedure Check_geo_source_code(
 p_site_id_num                  IN              varchar2
,p_geo_source_code              IN              varchar2
,x_return_flag                  OUT NOCOPY      varchar2
);

Procedure Check_location_id(
p_site_id_num                   IN              varchar2
,p_location_id			IN 		number
,p_country_code			IN 		varchar2
,x_return_flag 			OUT NOCOPY	varchar2
);

Procedure Check_address1(
p_site_id_num                   IN              varchar2
,p_location_status              IN              varchar2
,p_location_id                  IN              number
,p_country_code                 IN              varchar2
,p_address1                     IN              varchar2
,x_return_flag                  OUT NOCOPY      varchar2
);

Procedure Check_location_country(
p_site_id_num                   IN              varchar2
,p_location_id                  IN              number
,p_country_code                 IN              varchar2
,x_return_flag                  OUT NOCOPY      varchar2
);

Procedure Write_interface_errors(
p_processing_errors       	IN 		RRS_PROCESSING_ERRORS_TAB
);

Procedure prepare_error_mesg(
 p_site_id                      IN              varchar2
,p_site_id_num                  IN              varchar2
,p_column_name                  IN              varchar2
,p_message_name                 IN              varchar2
,p_message_text                 IN              varchar2
,p_source_table_name            IN              varchar2
,p_destination_table_name       IN              varchar2
,p_process_status               IN              varchar2
,p_transaction_type             IN              varchar2
,p_batch_id                     IN              number
,p_processing_errors            IN OUT NOCOPY   RRS_PROCESSING_ERRORS_TAB
);

Procedure Create_sites(
p_batch_id                     	IN		number
,p_transaction_type             IN		varchar2
,p_purge_rows                IN              varchar2
,x_num_rows                     OUT NOCOPY	number
,x_return_status                OUT NOCOPY	varchar2
);


Procedure Update_sites(
p_batch_id                      IN                      number
,p_transaction_type             IN                      varchar2
,p_purge_rows                IN                      varchar2
,x_num_rows                     OUT NOCOPY              number
,x_return_status                OUT NOCOPY              varchar2
);

end RRS_IMPORT_INTERFACE_PKG;

/
