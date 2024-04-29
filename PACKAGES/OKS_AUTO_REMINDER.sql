--------------------------------------------------------
--  DDL for Package OKS_AUTO_REMINDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_AUTO_REMINDER" AUTHID CURRENT_USER AS
/* $Header: OKSARNWS.pls 120.3.12000000.2 2007/02/28 23:45:23 skkoppul ship $ */

  --------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------

  G_REQUIRED_VALUE            CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE             CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN            CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKS_AUTO_REM_UNEXPECTED_ERR';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'SQLCODE';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'SQLERRM';

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION   EXCEPTION;
  G_EXCEPTION_ERROR             EXCEPTION;
  G_EXCEPTION_ROLLBACK          EXCEPTION;
  G_EXCEPTION_UNEXPECTED_ERROR  EXCEPTION;
  G_EXC_WARNING                 EXCEPTION;
  G_ERROR                       EXCEPTION;
  G_HALT_AUTO_RENEWAL           EXCEPTION;
  G_EXCEPTION_LOG_VALIDATION    EXCEPTION;

  -------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  -------------------------------------------------------------------------
   G_APP_NAME	               CONSTANT VARCHAR2(3)   :=  'OKS';
   G_AUTO_RENEWAL_RULE         CONSTANT VARCHAR2(3)   :=  'ERN';
   G_EVER_GREEN	               CONSTANT VARCHAR2(3)   :=  'EVN';
   G_NOTIFY_S_REP              CONSTANT VARCHAR2(3)   :=  'NSR';

   G_ERN_WEB_RESPONSIBILITY    CONSTANT VARCHAR2(20)  :=  'OKS_ERN_WEB';

   TYPE contract_rec_type IS RECORD
       (
          contract_id           NUMBER,
          contract_number       VARCHAR2(120),
          contract_modifier     VARCHAR2(120),
          start_date            DATE,
          end_date              DATE,
          QTO_email             VARCHAR2(2000),
          contract_status       VARCHAR2(50),
          renewal_status        VARCHAR2(40)
       );

   TYPE contract_rec_tbl IS TABLE OF contract_rec_type INDEX BY BINARY_INTEGER;

   TYPE contract_details_rec_type IS RECORD
       (
          id           NUMBER,
          contract_number       VARCHAR2(120),
          start_date            DATE,
          end_date              DATE,
          contract_number_modifier     VARCHAR2(240),
          sts_code              VARCHAR2(50),
          ste_code              VARCHAR2(200)
       );

   TYPE contract_details_tbl_type IS TABLE OF contract_details_rec_type INDEX BY BINARY_INTEGER;
   TYPE contact_rec_type IS RECORD
       (
          name                  VARCHAR2(240),
          phone                 VARCHAR2(240),
          fax                   VARCHAR2(240),
          email_address         VARCHAR2(2000),
          address1              VARCHAR2(240),
          address2              VARCHAR2(240),
          address3              VARCHAR2(240),
          address4              VARCHAR2(240),
          city                  VARCHAR2(240),
          postal_code           VARCHAR2(240),
          state                 VARCHAR2(240),
          party_name            VARCHAR2(360)
       );

   TYPE contact_rec_tbl IS TABLE OF contact_rec_type INDEX BY BINARY_INTEGER;

   TYPE message_rec_type IS RECORD
       (
          name                  VARCHAR2(120),
          description           VARCHAR2(4000)
       );

   TYPE message_rec_tbl IS TABLE OF message_rec_type INDEX BY BINARY_INTEGER;

   TYPE userinfo_rec_type IS RECORD
       (
          id           NUMBER,
          name         VARCHAR2(100),
          resource_id  NUMBER
       );

   TYPE userinfo_tbl IS TABLE OF userinfo_rec_type INDEX BY BINARY_INTEGER;




   PROCEDURE update_contract_status (
                               p_chr_id             IN         VARCHAR2,
                               p_status             IN         VARCHAR2,
                               x_return_status      OUT NOCOPY VARCHAR2
                               );

   PROCEDURE update_contract_status (
                               p_chr_id             IN         NUMBER,
                               p_status             IN         VARCHAR2,
                               x_return_status      OUT NOCOPY VARCHAR2
                               );

   PROCEDURE get_time_stats (
           p_start_date          IN         DATE,
           p_end_date            IN         DATE,
           x_duration            OUT NOCOPY NUMBER,
           x_period              OUT NOCOPY VARCHAR2,
           x_return_status       OUT NOCOPY VARCHAR2
         );

   PROCEDURE get_duration (
           p_start_date          IN         DATE,
           p_end_date            IN         DATE,
           p_source_uom          IN         VARCHAR2,
           x_duration            OUT NOCOPY NUMBER
         );

   FUNCTION get_org_context RETURN NUMBER;

   FUNCTION get_org_id RETURN VARCHAR2;

   FUNCTION get_org_context(p_org_id NUMBER) RETURN NUMBER;


   PROCEDURE validate_autoreminder_k (
           p_chr_id              IN         VARCHAR2,
           x_is_eligible         OUT NOCOPY VARCHAR2,
           x_quote_id            OUT NOCOPY VARCHAR2,
           x_cover_id            OUT NOCOPY VARCHAR2,
           x_sender              OUT NOCOPY VARCHAR2,
           x_QTO_email           OUT NOCOPY VARCHAR2,
           x_subject             OUT NOCOPY VARCHAR2,
           x_status              OUT NOCOPY VARCHAR2,
           x_attachment_name     OUT NOCOPY VARCHAR2,
           x_return_status       OUT NOCOPY VARCHAR2,
           x_msg_count           OUT NOCOPY VARCHAR2,
           x_msg_data            OUT NOCOPY VARCHAR2
         );


   PROCEDURE create_user (
                   p_user_name         IN         VARCHAR2,
                   p_contract_id       IN         NUMBER,
                   x_password          OUT NOCOPY VARCHAR2,
                   x_return_status     OUT NOCOPY VARCHAR2,
                   x_err_msg           OUT NOCOPY OKS_AUTO_REMINDER.message_rec_tbl
                   );

   PROCEDURE get_QTO_email (       p_chr_id        IN         NUMBER,
                                   x_QTO_email     OUT NOCOPY VARCHAR2
                           );


   PROCEDURE get_party_id (p_chr_id              IN         NUMBER,
                           x_party_id            OUT NOCOPY NUMBER
                          );

   PROCEDURE get_qtoparty_id (
                   p_chr_id              IN         NUMBER,
                   x_party_id            OUT NOCOPY NUMBER
               );



   PROCEDURE update_renewal_status (
                          p_chr_id             IN         NUMBER,
                          p_renewal_status     IN         VARCHAR2,
                          x_return_status      OUT NOCOPY VARCHAR2
                         );


   FUNCTION GET_BILLTO_CONTACT
               ( p_org_id      IN NUMBER,
                 p_inv_org_id  IN NUMBER,
                 p_contract_id IN NUMBER )
         RETURN  VARCHAR2;

   FUNCTION GET_BILLTO_EMAIL (
                p_contract_id IN NUMBER
             ) RETURN  VARCHAR2;

   FUNCTION GET_BILLTO_FAX (
                p_contract_id IN NUMBER
            ) RETURN  VARCHAR2;

   FUNCTION GET_BILLTO_PHONE (
                 p_contract_id IN NUMBER
             ) RETURN  VARCHAR2;

   FUNCTION GET_LICENSE_LEVEL
                ( p_lse_id    IN NUMBER,
                  p_object_id IN NUMBER)
        RETURN  VARCHAR2;

   FUNCTION GET_NO_OF_USERS
            ( p_lse_id    IN NUMBER,
              p_object_id IN NUMBER)
        RETURN  VARCHAR2;

   FUNCTION GET_PRICING_TYPE
            ( p_lse_id    IN NUMBER,
              p_object_id IN NUMBER)
        RETURN  VARCHAR2;

  FUNCTION GET_PRODUCT_NAME
          ( p_lse_id       IN NUMBER,
            p_object_id    IN NUMBER,
            p_inv_org_id   IN NUMBER DEFAULT NULL
          ) RETURN  VARCHAR2;

   FUNCTION GET_SERVICE_NAME
            ( p_line_id     IN NUMBER,
              p_contract_id IN NUMBER)
        RETURN  VARCHAR2;

   PROCEDURE log_interaction (
                        x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count      OUT NOCOPY NUMBER,
                        x_msg_data       OUT NOCOPY VARCHAR2,
                        p_chr_id         IN         VARCHAR2,
                        p_subject        IN         VARCHAR2 DEFAULT NULL,
                        p_msg_body       IN         VARCHAR2 DEFAULT NULL,
                        p_sent2_email    IN         VARCHAR2 DEFAULT NULL
                );

   PROCEDURE log_interaction (
                        p_api_version    IN         NUMBER,
                        p_init_msg_list  IN         VARCHAR2,
                        x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count      OUT NOCOPY NUMBER,
                        x_msg_data       OUT NOCOPY VARCHAR2,
                        p_chr_id         IN         NUMBER,
                        p_subject        IN         VARCHAR2 DEFAULT NULL,
                        p_msg_body       IN         VARCHAR2 DEFAULT NULL,
                        p_sent2_email    IN         VARCHAR2 DEFAULT NULL,
                        p_media_type     IN         VARCHAR2 DEFAULT 'EMAIL'
                );

PROCEDURE create_sso_user
(
 p_user_name         IN         VARCHAR2,
 p_contract_id       IN         NUMBER,
 x_user_name         OUT NOCOPY VARCHAR2,
 x_password          OUT NOCOPY VARCHAR2,
 x_return_status     OUT NOCOPY VARCHAR2,
 x_msg_data	     OUT NOCOPY VARCHAR2,
 x_msg_count	     OUT NOCOPY NUMBER

);

END OKS_AUTO_REMINDER;

 

/
