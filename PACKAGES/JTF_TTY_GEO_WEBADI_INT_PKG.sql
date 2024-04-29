--------------------------------------------------------
--  DDL for Package JTF_TTY_GEO_WEBADI_INT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TTY_GEO_WEBADI_INT_PKG" AUTHID CURRENT_USER AS
/* $Header: jtfgtwps.pls 120.2 2005/09/22 23:14:23 shli ship $ */
-- ===========================================================================+
-- |               Copyright (c) 1999 Oracle Corporation                       |
-- |                  Redwood Shores, California, USA                          |
-- |                       All rights reserved.                                |
-- +===========================================================================
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TTY_GEO_WEBADI_INTERFACE_PKG
--    ---------------------------------------------------
--    PURPOSE
--
--      This package is used to return a list of column in order of selectivity.
--      And create indices on columns in order of  input
--
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      06/20/2002    SHLI        Created
--
--    End of Comments
--
-- *******************************************************
--    Start of Comments
-- *******************************************************

 TYPE VARRAY_TYPE IS VARRAY(20) OF VARCHAR(360);
 TYPE NARRAY_TYPE IS VARRAY(20) OF NUMBER;



procedure POPULATE_INTERFACE(          p_userid         in varchar2,
                                       p_geoterrlist    in varchar2,
                                       x_seq            out NOCOPY varchar2);

procedure isDefaultTerr(terr_id IN number, flag out NOCOPY varchar2);


procedure UPDATE_GEO_TERR   (      --p_user_sequence      in varchar2,
                                   p_terrgroup          in varchar2,
                                   p_manager_terr_name  in varchar2,
                                   p_country            in varchar2,
                                   p_state_province     in varchar2,
                                   p_city               in varchar2,
                                   p_postal_code        in varchar2,
                                   p_geo_terr_name      in varchar2,
                                   p_geo_terr_value_id  in varchar2,
                                   p_userid             in varchar2
                            );

END JTF_TTY_GEO_WEBADI_INT_PKG;

 

/
