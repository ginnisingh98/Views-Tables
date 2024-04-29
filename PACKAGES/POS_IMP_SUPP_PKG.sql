--------------------------------------------------------
--  DDL for Package POS_IMP_SUPP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_IMP_SUPP_PKG" AUTHID CURRENT_USER AS
/* $Header: POSBATCHPS.pls 120.1.12010000.1 2009/12/14 14:41:07 ntungare noship $ */

  PROCEDURE pre_import_counts
  (
    p_batch_id        IN NUMBER,
    p_original_system IN VARCHAR2
  );

  PROCEDURE activate_batch
  (
    p_init_msg_list IN VARCHAR2 := fnd_api.g_false,
    p_batch_id      IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2
  );

  PROCEDURE reject_batch
  (
    p_init_msg_list IN VARCHAR2 := fnd_api.g_false,
    p_batch_id      IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2
  );

  PROCEDURE purge_batch
  (
    errbuf     OUT NOCOPY VARCHAR2,
    retcode    OUT NOCOPY VARCHAR2,
    p_batch_id IN VARCHAR2
  );

  PROCEDURE create_import_batch
  (
    p_batch_id          IN NUMBER,
    p_batch_name        IN VARCHAR2,
    p_description       IN VARCHAR2,
    p_original_system   IN VARCHAR2,
    p_load_type         IN VARCHAR2,
    p_est_no_of_records IN NUMBER,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2
  );

  FUNCTION func_batch_status
  (
    p_party_batch_status IN VARCHAR2,
    p_supp_batch_status  IN VARCHAR2
  ) RETURN VARCHAR2;

END POS_IMP_SUPP_PKG;

/
