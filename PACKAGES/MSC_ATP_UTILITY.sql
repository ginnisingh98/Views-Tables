--------------------------------------------------------
--  DDL for Package MSC_ATP_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_ATP_UTILITY" AUTHID CURRENT_USER AS
/* $Header: MSCASDUS.pls 120.1 2007/12/12 10:19:42 sbnaik ship $ */

PROCEDURE Close_DbLink(p_DbLink VARCHAR2);

PROCEDURE Derive_Profile_Values_Frm_Dest (p_SqlErrM        OUT NOCOPY VARCHAR2
                                        , p_Profile_Values OUT NOCOPY VARCHAR2
                                        , p_Profile_Names   IN VARCHAR2
                                        , p_Delimiter       IN VARCHAR2);

PROCEDURE Derive_Profile_Values_Frm_Sour (p_SqlErrM        OUT NOCOPY VARCHAR2
                                        , p_Profile_Values OUT NOCOPY VARCHAR2
                                        , p_Profile_Names   IN VARCHAR2
                                        , p_Delimiter       IN VARCHAR2
                                        , p_DbLink          IN VARCHAR2);

END MSC_ATP_UTILITY;

/
