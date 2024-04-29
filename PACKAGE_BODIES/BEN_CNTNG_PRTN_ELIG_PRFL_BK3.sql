--------------------------------------------------------
--  DDL for Package Body BEN_CNTNG_PRTN_ELIG_PRFL_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CNTNG_PRTN_ELIG_PRFL_BK3" as
/* $Header: becgpapi.pkb 120.0 2005/05/28 01:01:37 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:38:01 (YYYY/MM/DD HH24:MI:SS)
procedure DELETE_CNTNG_PRTN_ELIG_PRFL_A
(P_CNTNG_PRTN_ELIG_PRFL_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_CNTNG_PRTN_ELIG_PRFL_BK3.DELETE_CNTNG_PRTN_ELIG_PRFL_A', 10);
hr_utility.set_location(' Leaving: BEN_CNTNG_PRTN_ELIG_PRFL_BK3.DELETE_CNTNG_PRTN_ELIG_PRFL_A', 20);
end DELETE_CNTNG_PRTN_ELIG_PRFL_A;
procedure DELETE_CNTNG_PRTN_ELIG_PRFL_B
(P_CNTNG_PRTN_ELIG_PRFL_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_CNTNG_PRTN_ELIG_PRFL_BK3.DELETE_CNTNG_PRTN_ELIG_PRFL_B', 10);
hr_utility.set_location(' Leaving: BEN_CNTNG_PRTN_ELIG_PRFL_BK3.DELETE_CNTNG_PRTN_ELIG_PRFL_B', 20);
end DELETE_CNTNG_PRTN_ELIG_PRFL_B;
end BEN_CNTNG_PRTN_ELIG_PRFL_BK3;

/
