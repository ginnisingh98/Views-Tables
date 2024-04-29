--------------------------------------------------------
--  DDL for Package QA_TCA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_TCA_PKG" AUTHID CURRENT_USER AS
/* $Header: qatcas.pls 120.0 2005/05/24 18:29:13 appldev noship $ */

    PROCEDURE party_merge(
        p_entity_name          IN            VARCHAR2,
        p_from_id              IN            NUMBER,
        x_to_id                IN OUT NOCOPY NUMBER,
        p_from_fk_id           IN            NUMBER,
        p_to_fk_id             IN            NUMBER,
        p_parent_entity_name   IN            VARCHAR2,
        p_batch_id             IN            NUMBER,
        p_batch_party_id       IN            NUMBER,
        x_return_status        OUT NOCOPY    VARCHAR2);

END qa_tca_pkg;

 

/
