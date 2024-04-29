--------------------------------------------------------
--  DDL for Package HXT_HEP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXT_HEP" AUTHID CURRENT_USER AS
/* $Header: hxtepdml.pkh 120.0 2005/05/29 06:03:01 appldev noship $ */

procedure insert_HXT_EARNING_POLICIES(
p_rowid                      IN OUT NOCOPY VARCHAR2,
p_id                         NUMBER,
p_hcl_id                     NUMBER,
p_fcl_earn_type              VARCHAR2,
p_name                       VARCHAR2,
p_business_group_id          NUMBER,  --HXT11i1
p_effective_start_date       DATE,
p_pip_id                     NUMBER,
p_pep_id                     NUMBER,
p_egt_id                     NUMBER,
p_description                VARCHAR2,
p_effective_end_date         DATE,
p_created_by                 NUMBER,
p_creation_date              DATE,
p_last_updated_by            NUMBER,
p_last_update_date           DATE,
p_last_update_login          NUMBER,
p_organization_id            NUMBER,
p_round_up                   NUMBER,
p_min_tcard_intvl            NUMBER,
p_use_points_assigned        VARCHAR2
);

procedure update_HXT_EARNING_POLICIES(
p_rowid                      IN VARCHAR2,
p_id                         NUMBER,
p_hcl_id                     NUMBER,
p_fcl_earn_type              VARCHAR2,
p_name                       VARCHAR2,
p_business_group_id          NUMBER,  --HXT11i1
p_effective_start_date       DATE,
p_pip_id                     NUMBER,
p_pep_id                     NUMBER,
p_egt_id                     NUMBER,
p_description                VARCHAR2,
p_effective_end_date         DATE,
p_created_by                 NUMBER,
p_creation_date              DATE,
p_last_updated_by            NUMBER,
p_last_update_date           DATE,
p_last_update_login          NUMBER,
p_organization_id            NUMBER,
p_round_up                   NUMBER,
p_min_tcard_intvl            NUMBER,
p_use_points_assigned        VARCHAR2
);

procedure delete_HXT_EARNING_POLICIES(p_rowid VARCHAR2);

procedure lock_HXT_EARNING_POLICIES(p_rowid VARCHAR2);

END HXT_HEP;

 

/
