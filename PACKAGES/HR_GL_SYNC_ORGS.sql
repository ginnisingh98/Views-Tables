--------------------------------------------------------
--  DDL for Package HR_GL_SYNC_ORGS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_GL_SYNC_ORGS" AUTHID CURRENT_USER AS
   -- $Header: hrglsync.pkh 120.1 2005/06/22 02:18:41 adudekul noship $

   --
   -- Due to  potentially heavy memory usage by this package, restrict
   -- package data life to current call only.
   --
   -- Fix for bug 4445934. Comment out the pragma serially_reusable.
   --
   -- PRAGMA SERIALLY_REUSABLE;


   --
   -- Public program unit accessed in the following ways:-
   -- 1) Concurrent Program - Create/Maintain Company CostCenter Orgs
   -- 2) Concurrent Program - Synchronize GL Company CostCenter Orgs
   -- 3) Concurrent Program - Export/Reporting Mode
   --
   PROCEDURE sync_orgs( errbuf              IN OUT NOCOPY VARCHAR2
                      , retcode             IN OUT NOCOPY NUMBER
                      , p_mode              IN            VARCHAR2
                      , p_business_group_id IN            NUMBER
                      , p_coa_id            IN            NUMBER
                      , p_co                IN            VARCHAR2
                      , p_ccid              IN            NUMBER
                      , p_source            IN            VARCHAR2
                      , p_sync_org_name     IN            VARCHAR2 DEFAULT 'N'
                      , p_sync_org_dates    IN            VARCHAR2 DEFAULT 'N'
                      );


   --
   -- Public program unit accessed in the following ways:-
   -- 1) Code Hook - GL Create Code Combination
   --
   PROCEDURE sync_single_org( p_ccid IN NUMBER
                            );

END hr_gl_sync_orgs;

 

/
