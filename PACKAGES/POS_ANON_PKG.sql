--------------------------------------------------------
--  DDL for Package POS_ANON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_ANON_PKG" AUTHID CURRENT_USER AS
/*$Header: POSANONS.pls 120.1 2005/10/03 14:03:39 bitang noship $ */

FUNCTION make_anonymous_login(p_registration_key IN VARCHAR2,
                              x_session_id       OUT NOCOPY NUMBER,
                              x_transaction_id   OUT NOCOPY NUMBER)
RETURN VARCHAR2;

PROCEDURE confirm_has_resp(
                  p_responsibility_key      IN  VARCHAR2);

PROCEDURE get_various_login_info(
                  p_raw_session_id          IN  VARCHAR2,
                  p_raw_transaction_id      IN  VARCHAR2,
                  p_responsibility_key      IN  VARCHAR2,
                  x_dbc_name                OUT NOCOPY VARCHAR2,
                  x_enc_session_id          OUT NOCOPY VARCHAR2,
                  x_enc_transaction_id      OUT NOCOPY VARCHAR2,
                  x_application_id          OUT NOCOPY VARCHAR2,
                  x_responsibility_id       OUT NOCOPY VARCHAR2);

PROCEDURE get_various_session_info(
    x_session_cookie_name     OUT NOCOPY VARCHAR2,
    x_session_cookie_domain   OUT NOCOPY VARCHAR2);

END pos_anon_pkg;


 

/
