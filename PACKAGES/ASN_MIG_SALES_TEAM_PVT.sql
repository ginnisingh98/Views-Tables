--------------------------------------------------------
--  DDL for Package ASN_MIG_SALES_TEAM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASN_MIG_SALES_TEAM_PVT" AUTHID CURRENT_USER AS
/* $Header: asnvmsts.pls 120.3 2007/12/21 09:32:13 snsarava ship $ */

  --
  --
  -- Start of Comments
  --
  -- NAME
  --   asn_mig_sales_team_pvt
  --
  -- PURPOSE
  --   This package contains migration related code for sales team.
  --
  -- NOTES
  --
  -- HISTORY
  -- sumahali      01/09/2005           Created
  -- **********************************************************************************************************


--
--

PROCEDURE Mig_Dup_SalesRep_Main
          (
           errbuf          OUT NOCOPY VARCHAR2,
           retcode         OUT NOCOPY NUMBER,
           p_num_workers   IN NUMBER,
           p_commit_flag   IN VARCHAR2,
           p_debug_flag    IN VARCHAR2
          );

PROCEDURE Mig_Dup_SalesRep_Opp (
    errbuf           OUT NOCOPY VARCHAR2,
    retcode          OUT NOCOPY NUMBER,
    p_start_id       IN VARCHAR2,
    p_end_id         IN VARCHAR2,
    p_commit_flag    IN VARCHAR2,
    p_batch_size     IN NUMBER,
    p_debug_flag     IN VARCHAR2
    );

PROCEDURE Mig_Dup_SalesRep_Lead (
    errbuf           OUT NOCOPY VARCHAR2,
    retcode          OUT NOCOPY NUMBER,
    p_start_id       IN VARCHAR2,
    p_end_id         IN VARCHAR2,
    p_commit_flag    IN VARCHAR2,
    p_batch_size     IN NUMBER,
    p_debug_flag     IN VARCHAR2
    );


PROCEDURE Mig_Dup_SalesRep_Cust (
    errbuf           OUT NOCOPY VARCHAR2,
    retcode          OUT NOCOPY NUMBER,
    p_start_id       IN VARCHAR2,
    p_end_id         IN VARCHAR2,
    p_commit_flag    IN VARCHAR2,
    p_batch_size     IN NUMBER,
    p_debug_flag     IN VARCHAR2
    );

PROCEDURE Mig_Customerid_Enddaylog_Main
          (
           errbuf          OUT NOCOPY VARCHAR2,
           retcode         OUT NOCOPY NUMBER,
           p_num_workers   IN NUMBER,
           p_commit_flag   IN VARCHAR2,
           p_debug_flag    IN VARCHAR2
          );

PROCEDURE Mig_Customerid_Enddaylog_sub (
    errbuf           OUT NOCOPY VARCHAR2,
    retcode          OUT NOCOPY NUMBER,
    p_start_id       IN VARCHAR2,
    p_end_id         IN VARCHAR2,
    p_commit_flag    IN VARCHAR2,
    p_batch_size     IN NUMBER,
    p_debug_flag     IN VARCHAR2
    );


END asn_mig_sales_team_pvt;

/
