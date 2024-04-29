--------------------------------------------------------
--  DDL for Package PA_MRC_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_MRC_UTILS" AUTHID CURRENT_USER AS
/* $Header: PAMRCTRS.pls 120.0 2005/06/03 13:34:52 appldev noship $ */

-- ========================================================================
-- PROCEDURE EnableMRCTriggers
-- ========================================================================

PROCEDURE  EnableMRCTriggers(  p_Calling_Mode           IN     VARCHAR2
                             , X_err_code               IN OUT NOCOPY NUMBER
                             , X_err_stage              IN OUT NOCOPY VARCHAR2 ) ;


end ;

 

/
