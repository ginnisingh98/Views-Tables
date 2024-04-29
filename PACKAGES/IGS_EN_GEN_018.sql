--------------------------------------------------------
--  DDL for Package IGS_EN_GEN_018
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_GEN_018" AUTHID CURRENT_USER AS
/* $Header: IGSENA8S.pls 115.1 2003/10/31 05:31:18 rvivekan noship $ */

PROCEDURE enrp_batch_sua_upload(
  Errbuf		OUT NOCOPY VARCHAR2,
  Retcode		OUT NOCOPY NUMBER,
  p_batch_id		IN  NUMBER,
  p_dflt_unit_confirmed IN VARCHAR2,
  p_ovr_enr_method	IN VARCHAR2,
  p_deletion_flag	IN VARCHAR2);

FUNCTION enrp_get_uoo_info (
  p_unit_cd            IN VARCHAR2,
  p_unit_ver           IN NUMBER,
  p_cal_type           IN VARCHAR2,
  p_ci_sequence_number IN NUMBER,
  p_location_cd        IN VARCHAR2,
  p_unit_class         IN VARCHAR2)
RETURN VARCHAR2;

PROCEDURE enrp_decode_uoo_info (
  p_uoo_info              IN VARCHAR2,
  p_uoo_id                OUT NOCOPY NUMBER,
  p_rel_type              OUT NOCOPY VARCHAR2,
  p_audit_allowed         OUT NOCOPY VARCHAR2,
  p_usec_status           OUT NOCOPY VARCHAR2,
  p_sup_unit              OUT NOCOPY VARCHAR2);

FUNCTION enrp_get_unitcds (
  p_uoo_ids               IN VARCHAR2)
RETURN VARCHAR2;

END igs_en_gen_018;

 

/
