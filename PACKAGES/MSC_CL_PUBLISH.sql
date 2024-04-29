--------------------------------------------------------
--  DDL for Package MSC_CL_PUBLISH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_CL_PUBLISH" AUTHID CURRENT_USER AS
/* $Header: MSCXCPS.pls 115.7 2003/11/12 02:14:16 pshah ship $ */

    TYPE number_arr IS TABLE OF NUMBER;
	TYPE acceptance_flags IS TABLE OF msc_sup_dem_entries.acceptance_required_flag%TYPE;

    TYPE shippingControlList    IS TABLE OF msc_trading_partner_sites.shipping_control%TYPE;

    PROCEDURE PUBLISH (ERRBUF		OUT NOCOPY VARCHAR2,
		       RETCODE		OUT NOCOPY NUMBER,
		       p_sr_instance_id	NUMBER,
    		   p_user_id	NUMBER,
	           p_po_enabled_flag	NUMBER,
		       p_oh_enabled_flag	NUMBER,
		       p_so_enabled_flag	NUMBER,
		       p_asl_enabled_flag	NUMBER,
		       p_sup_resp_flag		NUMBER,
               p_po_sn_flag         NUMBER,
               p_oh_sn_flag         NUMBER,
               p_so_sn_flag         NUMBER,
			   p_suprep_sn_flag     NUMBER
		      );

/* Global parameters for Conncurrent request purpose */
   G_SUCCESS                    CONSTANT NUMBER := 0;
   G_WARNING                    CONSTANT NUMBER := 1;
   G_ERROR                      CONSTANT NUMBER := 2;

/* Global Parameters for Automatic Collections purpose */
   G_AUTO_NO_COLL               CONSTANT NUMBER := 2;
   G_AUTO_NET_COLL              CONSTANT NUMBER := 3;
   G_AUTO_TAR_COLL              CONSTANT NUMBER := 4;

   SYS_YES                      CONSTANT NUMBER := 1;
   SYS_NO                       CONSTANT NUMBER := 2;
   G_MSC_DEBUG   VARCHAR2(1) := nvl(FND_PROFILE.Value('MRP_DEBUG'),'N');

END;

 

/
