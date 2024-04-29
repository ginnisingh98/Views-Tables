--------------------------------------------------------
--  DDL for Package ASN_MIG_SALES_CREDITS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASN_MIG_SALES_CREDITS_PVT" AUTHID CURRENT_USER AS
/* $Header: asnvmscs.pls 120.0 2005/06/01 01:16:45 appldev noship $ */

PROCEDURE Mig_SlsCred_Owner_Main
          (
           errbuf OUT NOCOPY VARCHAR2,
           retcode OUT NOCOPY NUMBER,
           p_num_workers IN NUMBER,
           p_commit_flag IN VARCHAR2,
           p_debug_flag IN VARCHAR2
          );

PROCEDURE Mig_SlsCred_Owner_Sub
          (
           errbuf OUT NOCOPY VARCHAR2,
           retcode OUT NOCOPY NUMBER,
           p_start_id IN VARCHAR2,
           p_end_id IN VARCHAR2,
           p_commit_flag IN VARCHAR2,
           p_debug_flag IN VARCHAR2
          );

PROCEDURE Mig_Multi_SalesRep_Opp_Main
          (
           errbuf OUT NOCOPY VARCHAR2,
           retcode OUT NOCOPY NUMBER,
           p_num_workers IN NUMBER,
           p_commit_flag IN VARCHAR2,
           p_debug_flag IN VARCHAR2
          );

PROCEDURE Mig_Multi_SalesRep_Opp_sub (
    errbuf OUT NOCOPY VARCHAR2,
    retcode OUT NOCOPY NUMBER,
    p_start_id IN VARCHAR2,
    p_end_id IN VARCHAR2,
    p_commit_flag IN VARCHAR2,
    p_batch_size  IN NUMBER,
    p_debug_flag IN VARCHAR2
   );

END asn_mig_sales_credits_pvt;

 

/
