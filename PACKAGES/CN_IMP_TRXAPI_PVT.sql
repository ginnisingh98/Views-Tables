--------------------------------------------------------
--  DDL for Package CN_IMP_TRXAPI_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_IMP_TRXAPI_PVT" AUTHID CURRENT_USER AS
-- $Header: cnvimtxs.pls 120.2 2005/08/07 23:04:39 vensrini noship $

-- * ------------------------------------------------------------------+
--   Record Type Definition
-- * ------------------------------------------------------------------+

-- Start of comments
--    API name        : Trxapi_Import
--    Type            : Private.
--    Function        : programtransfer data from staging table into
--                      cn_comm_lines_api_all
--    Pre-reqs        : None.
--    Parameters      :
--    IN                  p_imp_header_id           IN    NUMBER,
--    OUT              : errbuf         OUT VARCHAR2       Required
--                      retcode        OUTVARCHAR2     Optional
--    Version :         Current version       1.0
--
--
--
--    Notes           : Note text
--
-- End of comments

PROCEDURE Trxapi_Import
 ( errbuf                     OUT NOCOPY   VARCHAR2,
   retcode                    OUT NOCOPY   VARCHAR2,
   p_imp_header_id           IN    NUMBER,
   p_org_id		     IN NUMBER
   );

END CN_IMP_TRXAPI_PVT;

 

/
