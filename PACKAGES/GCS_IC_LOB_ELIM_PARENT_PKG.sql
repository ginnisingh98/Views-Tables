--------------------------------------------------------
--  DDL for Package GCS_IC_LOB_ELIM_PARENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_IC_LOB_ELIM_PARENT_PKG" AUTHID CURRENT_USER AS
 /*$Header: gcsiclbs.pls 120.2 2006/11/09 20:23:13 skamdar noship $ */

--
-- Package
--   CREATE_ELIM_PARENT_LOB
-- Purpose
--   Creates the elimination parent elimination line of business.
-- History
--   17-AUG-04    Srini Pala       Created
--

   PROCEDURE  CREATE_ELIM_PARENT_LOB (p_errbuf OUT NOCOPY VARCHAR2,
                                      p_retcode OUT NOCOPY VARCHAR2,
                                      p_hierarchy_name   IN VARCHAR2,
                                      p_hierarchy_obj_id IN VARCHAR2,
                                      p_version_name     IN VARCHAR2
                                      );



END GCS_IC_LOB_ELIM_PARENT_PKG;

/
