--------------------------------------------------------
--  DDL for Package FND_DELIVERY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_DELIVERY" AUTHID CURRENT_USER as
/* $Header: AFCPDELS.pls 120.0.12010000.8 2013/02/22 21:31:29 ckclark noship $ */

  --
  -- PUBLIC VARIABLES
  --


   --
   -- Delivery Types
   --
   TYPE_EMAIL        CONSTANT varchar2(1) := 'E';
   TYPE_IPP_PRINTER  CONSTANT varchar2(1) := 'P';
   TYPE_IPP_FAX      CONSTANT varchar2(1) := 'F';
   TYPE_FTP          CONSTANT varchar2(1) := 'T';
   TYPE_SFTP         CONSTANT varchar2(1) := 'S';
   TYPE_HTTP         CONSTANT varchar2(1) := 'H';
   TYPE_WEBDAV       CONSTANT varchar2(1) := 'W';
   TYPE_CUSTOM       CONSTANT varchar2(1) := 'C';
   TYPE_BURST        CONSTANT varchar2(1) := 'B';


   --
   -- Printer orientations
   --
   ORIENTATION_PORTRAIT   CONSTANT varchar2(1) := '3';
   ORIENTATION_LANDSCAPE  CONSTANT varchar2(1) := '4';


   --
   -- Variable names for FND_VAULT
   --
   DELIVERY_SERVICE CONSTANT varchar2(8):=  'FND_TMP_';
   SMTP_SERVICE     CONSTANT varchar2(8) := 'FND_SMTP';




  --
  -- PUBLIC FUNCTIONS
  --


   function add_email (subject         in varchar2,
		       from_address    in varchar2,
		       to_address      in varchar2,
		       cc              in varchar2 default null,
		       lang            in varchar2 default null) return boolean;

   function add_ipp_printer (printer_name in varchar2,
			     copies       in number default null,
			     orientation  in varchar2 default null,
			     username     in varchar2 default null,
			     password     in varchar2 default null,
			     lang         in varchar2 default null) return boolean;



   function add_ipp_printer (printer_id   in number,
			     copies       in number default null,
			     orientation  in varchar2 default null,
			     username     in varchar2 default null,
			     password     in varchar2 default null,
			     lang         in varchar2 default null) return boolean;


   function add_fax ( server_name   in varchar2,
		      fax_number    in varchar2,
		      username      in varchar2 default null,
	              password      in varchar2 default null,
		      lang          in varchar2 default null) return boolean;


   function add_fax ( server_id     in number,
		      fax_number    in varchar2,
		      username      in varchar2 default null,
	              password      in varchar2 default null,
		      lang          in varchar2 default null) return boolean;


   function add_ftp ( server     in varchar2,
		      username   in varchar2,
		      password   in varchar2,
		      remote_dir in varchar2,
		      port       in varchar2 default null,
		      secure     in boolean default FALSE,
		      lang       in varchar2 default null) return boolean;

   function add_webdav ( server     in varchar2,
                         remote_dir in varchar2,
                         port       in varchar2 default null,
		         username   in varchar2 default null,
		         password   in varchar2 default null,
		         authtype   in varchar2 default null,
                         enctype    in varchar2 default null,
		         lang       in varchar2 default null) return boolean;

   function add_http (   server     in varchar2,
                         remote_dir in varchar2,
                         port       in varchar2 default null,
		         username   in varchar2 default null,
		         password   in varchar2 default null,
		         authtype   in varchar2 default null,
                         enctype    in varchar2 default null,
                         method     in varchar2 default null,
		         lang       in varchar2 default null) return boolean;

   function add_custom ( custom_id   in number,
		         lang        in varchar2 default null) return boolean;

   function add_custom ( custom_name   in varchar2,
		         lang          in varchar2 default null) return boolean;

   function add_burst return boolean;

   function has_lob_of_type (  prog_app_name  IN varchar2,
                               conc_prog_name IN varchar2,
                               lob_of_type    IN varchar2,
                               nls_lang       IN varchar2 default null,
                               nls_terry      IN varchar2 default null)  return boolean;

   function has_lob_of_type (  reqid          IN number,
                               lob_of_type    IN varchar2)  return boolean;

   function has_delivery_of_type ( reqid          IN number,
                                   delivery_type  IN varchar2)  return boolean;

   function  post_processing_results ( reqid          IN number
                                                       )  return varchar2;

   procedure set_smtp_credentials( username  in varchar2,
				   smtp_user in varchar2,
				   smtp_pass in varchar2);

   procedure get_smtp_credentials( username  in varchar2,
				   smtp_user out nocopy varchar2,
				   smtp_pass out nocopy varchar2);

   function set_temp_credentials  (username in varchar2,
                                   password in varchar2) return varchar2;

   function get_temp_credentials  (svc_key  in varchar2,
                                   username in varchar2,
                                   delflag  in varchar2 default 'Y') return varchar2;

   procedure del_temp_credentials (svc_key  in varchar2,
                                   username in varchar2);

end FND_DELIVERY;

/
