--------------------------------------------------------
--  DDL for Package ZPB_BUILD_METADATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZPB_BUILD_METADATA" AUTHID CURRENT_USER as
/* $Header: zpbbuildmeta.pls 120.0.12010.4 2006/08/03 12:15:49 appldev noship $ */

-------------------------------------------------------------------------------
-- BUILD_CALC_MEASURE - Builds views/metadata map for a calc measure
--
-- IN: p_aw - The AW name
--     p_instance - The instance ID
--     p_type - Either SHARED (controlled calc) or PERSONAL (analyst)
-------------------------------------------------------------------------------
procedure build_calc_measure (p_aw          in varchar2,
                              p_instance    in varchar2,
                              p_type        in varchar2);

-------------------------------------------------------------------------------
-- BUILD_CWM2_INSTANCE
--
-- Builds the CWM2 structures for a Cycle Instance
--
-- IN: p_aw       (varchar2) - The AW name
--     p_instance (varchar2)   - The instance ID
--     p_dims     (varchar2) - A space separated list of express dimensions6b
--
-------------------------------------------------------------------------------
procedure build_cwm2_instance (p_aw       in varchar2,
                               p_instance in varchar2,
                               p_dims     in varchar2,
                               p_currInst in boolean default false);

-------------------------------------------------------------------------------
-- BUILD_CWM2_METADATA
--
-- Builds the CWM2 structures for an AW
--
-- IN: p_aw (varchar2) - The AW name
-------------------------------------------------------------------------------
procedure build_cwm2_metadata (p_aw      in varchar2);

-------------------------------------------------------------------------------
-- BUILD_METADATA
--
-- Builds the ECM metadata, SQL views, security and CWM2 metadata for an AW.
-- This should be the only function called by outside programs.  The code AW
-- MUST be attached (likely RO), and the data and annot MUST be attached RW
-- before this function is called.
--
-- IN: p_business_area (number) - The Business Area ID to refresh
--
-------------------------------------------------------------------------------
procedure build_metadata (ERRBUF          OUT NOCOPY VARCHAR2,
                          RETCODE         OUT NOCOPY VARCHAR2,
                          P_BUSINESS_AREA IN         NUMBER);

-------------------------------------------------------------------------------
-- BUILD_OWNERMAP_MEASURE
--
-- Builds, on the fly, the ownermap measure for security.  Returns the
-- Metadata Map for the ownermap measure
-------------------------------------------------------------------------------
function build_ownermap_measure (p_userid   in varchar2,
                                 p_dim1     in varchar2,
                                 p_dim2     in varchar2)
   return varchar2;

-------------------------------------------------------------------------------
-- BUILD_SECURITY
--
-- Populates the security and CWM2 structures for an AW.
--
-------------------------------------------------------------------------------
procedure build_security;

-------------------------------------------------------------------------------
-- DROP_CWM2_METADATA
--
-- Removes the CWM2 metadata for an AW
-------------------------------------------------------------------------------
procedure drop_cwm2_metadata (p_dataAW in varchar2);

-------------------------------------------------------------------------------
-- SYNCHRONIZE_METADATA_SCOPING
--
-- Synchronizes the metadata scoping with the universe, removing any
-- scoping rules for hierarchies/levels/attributes that no longer exist
--
-------------------------------------------------------------------------------
procedure synchronize_metadata_scoping(p_business_area IN NUMBER);

-------------------------------------------------------------------------------
-- GET_QUERY_CM_USER_ID
--
-- Procedure to get the user ID to use for the Update Queries Conc. Req.
-- Need a user who has access to the system
-------------------------------------------------------------------------------
function GET_QUERY_CM_USER_ID(p_business_area IN NUMBER,
                              p_requestor     IN NUMBER)
   return NUMBER;

end ZPB_BUILD_METADATA;

 

/
