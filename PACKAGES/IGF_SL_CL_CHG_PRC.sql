--------------------------------------------------------
--  DDL for Package IGF_SL_CL_CHG_PRC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_CL_CHG_PRC" AUTHID CURRENT_USER AS
/* $Header: IGFSL23S.pls 120.0 2005/06/01 14:25:12 appldev noship $ */

  ------------------------------------------------------------------
  --Created by  : Sanil Madathil, Oracle IDC
  --Date created: 10 October 2004
  --
  --Purpose:
  -- Invoked     : From igf_sl_cl_create_chg process to validate change record
  -- Function    : This process would be invoked automatically for each change
  --               record created
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  ------------------------------------------------------------------

  TYPE token_rec_type IS RECORD (
  token_name  VARCHAR2(256),
  token_value VARCHAR2(1024)
  );

  token_rec token_rec_type;

  TYPE token_tab_type IS TABLE OF token_rec%TYPE INDEX BY BINARY_INTEGER;
  token_tab token_tab_type;
  g_message_tokens  token_tab%TYPE;

  PROCEDURE validate_chg       ( p_n_clchgsnd_id   IN  igf_sl_clchsn_dtls.clchgsnd_id%TYPE,
                                 p_b_return_status OUT NOCOPY BOOLEAN,
                                 p_v_message_name  OUT NOCOPY VARCHAR2,
                                 p_t_message_tokens  OUT NOCOPY token_tab%TYPE
                                );

  PROCEDURE parse_tokens       ( p_t_message_tokens  IN  token_tab%TYPE
                                );

END igf_sl_cl_chg_prc;

 

/
