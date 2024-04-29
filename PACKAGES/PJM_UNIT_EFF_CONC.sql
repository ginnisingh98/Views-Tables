--------------------------------------------------------
--  DDL for Package PJM_UNIT_EFF_CONC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJM_UNIT_EFF_CONC" AUTHID CURRENT_USER AS
/* $Header: PJMUEFCS.pls 115.7 2002/10/29 20:14:23 alaw ship $ */
--
--  Name          : Generate
--  Pre-reqs      : None
--  Function      : This function creates new unit numbers based on
--                  input parameters
--
--
--  Parameters    :
--  IN            : X_master_org_id                 NUMBER
--                  X_end_item_id                   NUMBER
--                  X_prefix                        VARCHAR2
--                  X_start_num                     NUMBER
--                  X_counts                        NUMBER
--                  X_numeric_width                 NUMBER
--
--  OUT           : ERRBUF                          VARCHAR2
--                  RETCODE                         NUMBER
--
--  Returns       : None
--
PROCEDURE Generate
( ERRBUF                           OUT NOCOPY    VARCHAR2
, RETCODE                          OUT NOCOPY    NUMBER
, X_master_org_id                  IN            NUMBER
, X_end_item_id                    IN            NUMBER
, X_prefix                         IN            VARCHAR2
, X_start_num                      IN            NUMBER
, X_counts                         IN            NUMBER
, X_numeric_width                  IN            NUMBER
);


--
--  Name          : Enable_OE_Support
--  Pre-reqs      : None
--  Function      : This function enabled Unit Effectivity support
--                  in Order Entry
--
--
--  Parameters    :
--  IN            : X_attribute                     VARCHAR2
--
--  OUT           : ERRBUF                          VARCHAR2
--                  RETCODE                         NUMBER
--
--  Returns       : None
--
-- PROCEDURE Enable_OE_Support
-- ( ERRBUF                           OUT    VARCHAR2
-- , RETCODE                          OUT    NUMBER
-- , X_attribute                      IN     VARCHAR2
-- );


END;

 

/
