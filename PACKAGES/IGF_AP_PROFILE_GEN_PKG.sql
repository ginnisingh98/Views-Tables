--------------------------------------------------------
--  DDL for Package IGF_AP_PROFILE_GEN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_PROFILE_GEN_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFAP48S.pls 120.0 2005/06/01 15:48:23 appldev noship $ */
------------------------------------------------------------------
--Created by  : ugummall, Oracle India
--Date created: 04-AUG-2004
--
--Purpose:  Generic routines used in self-service pages and PROFILE Import Process.
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
-------------------------------------------------------------------

PROCEDURE create_base_record  (
                                p_css_id        IN          NUMBER,
                                p_person_id     IN          NUMBER,
                                p_batch_year    IN          NUMBER,
                                x_msg_data      OUT NOCOPY  VARCHAR2,
                                x_return_status OUT NOCOPY  VARCHAR2
                              );

PROCEDURE create_person_record  (
                                  p_css_id        IN          NUMBER,
                                  p_person_id     OUT NOCOPY  NUMBER,
                                  p_batch_year    IN          NUMBER,
                                  x_msg_data      OUT NOCOPY  VARCHAR2,
                                  x_return_status OUT NOCOPY  VARCHAR2
                              );

PROCEDURE delete_person_match ( p_css_id   IN    NUMBER);

PROCEDURE delete_interface_record ( p_css_id        IN          NUMBER,
                                    x_return_status OUT NOCOPY  VARCHAR2
                                  );

PROCEDURE delete_int_records  ( p_css_ids  VARCHAR2 );

PROCEDURE ss_upload_profile ( p_css_id        IN          NUMBER,
                              x_msg_data      OUT NOCOPY  VARCHAR2,
                              x_return_status OUT NOCOPY  VARCHAR2
                            );

END igf_ap_profile_gen_pkg;

 

/
