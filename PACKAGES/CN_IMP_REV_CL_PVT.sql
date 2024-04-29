--------------------------------------------------------
--  DDL for Package CN_IMP_REV_CL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_IMP_REV_CL_PVT" AUTHID CURRENT_USER AS
-- $Header: cnvimrcs.pls 120.1 2005/08/07 23:04:10 vensrini noship $

-- * ------------------------------------------------------------------+
--   Record Type Definition
-- * ------------------------------------------------------------------+

-- Start of comments
--    API name        : RevCl_Import
--    Type            : Private.
--    Function        : programtransfer data from staging table into
--                      cn_revenue_classes
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

PROCEDURE RevCl_Import
 ( errbuf                     OUT NOCOPY   VARCHAR2,
   retcode                    OUT NOCOPY   VARCHAR2,
   p_imp_header_id           IN    NUMBER,
   p_org_id		     IN    NUMBER
   );

END CN_IMP_REV_CL_PVT;

 

/
