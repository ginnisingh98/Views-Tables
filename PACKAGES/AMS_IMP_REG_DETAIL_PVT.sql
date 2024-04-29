--------------------------------------------------------
--  DDL for Package AMS_IMP_REG_DETAIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_IMP_REG_DETAIL_PVT" AUTHID CURRENT_USER as
/* $Header: amsvimrs.pls 115.10 2003/02/07 18:25:35 soagrawa ship $ */
--

PROCEDURE LoadProcess(  errbuf OUT NOCOPY VARCHAR2
                      , retcode OUT NOCOPY NUMBER
                      , p_list_header_id IN NUMBER := NULL
                     );

-- Following procedure is modified by ptendulk on 21-Dec-2002
-- Added additional parameter for p_msg_count
PROCEDURE update_imp_src_line_rec(p_imp_src_id IN NUMBER
			, p_imp_hdr_id       IN  NUMBER
			, p_return_status    IN  VARCHAR2
			, p_msg_data         IN  VARCHAR2
         , p_msg_count        IN  NUMBER
-- soagrawa added out status on 03-feb-2003 for error threshold
         , p_out_status       OUT NOCOPY VARCHAR2);

PROCEDURE update_imp_hdr_rec(p_imp_hdr_id IN NUMBER
			, p_processed_rows    IN  NUMBER
			, p_failed_rows       IN  NUMBER);

END ams_imp_reg_detail_pvt;

 

/
