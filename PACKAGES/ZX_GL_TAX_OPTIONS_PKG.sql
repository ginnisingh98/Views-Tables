--------------------------------------------------------
--  DDL for Package ZX_GL_TAX_OPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_GL_TAX_OPTIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: zxgltaxoptions.pls 120.9 2005/12/15 02:48:23 nipatel ship $ */

PROCEDURE get_default_values
(   p_api_version      IN   NUMBER  DEFAULT NULL,
    p_ledger_id        IN   NUMBER,
    p_org_id           IN   NUMBER,
    p_le_id            IN   NUMBER,
    p_account_segment  IN   VARCHAR2,
    p_account_type     IN   VARCHAR2,
    p_trx_date         IN   DATE,
    x_default_regime_code       OUT   NOCOPY  VARCHAR2,
    x_default_tax               OUT   NOCOPY  VARCHAR2,
    x_default_tax_status_code   OUT   NOCOPY  VARCHAR2,
    x_default_tax_rate_code     OUT   NOCOPY  VARCHAR2,
    x_default_tax_rate_id       OUT   NOCOPY  NUMBER,
    x_default_rounding_code     OUT   NOCOPY  VARCHAR2,
    x_default_incl_tax_flag     OUT   NOCOPY  VARCHAR2,
    x_return_status             OUT   NOCOPY  VARCHAR2,
    x_msg_out                   OUT   NOCOPY  VARCHAR2
);


PROCEDURE get_tax_rate_and_account
(   p_api_version       IN   NUMBER   DEFAULT NULL,
    p_ledger_id         IN   NUMBER,
    p_org_id            IN   NUMBER,
    p_tax_type_code     IN   VARCHAR2,
    p_tax_rate_id       IN   NUMBER,
    x_tax_rate_pct      OUT  NOCOPY   NUMBER,
    x_tax_account_ccid  OUT  NOCOPY   NUMBER,
    x_return_status     OUT  NOCOPY   VARCHAR2,
    x_msg_out           OUT  NOCOPY   VARCHAR2
);


PROCEDURE get_tax_ccid
(  p_api_version        IN   NUMBER   DEFAULT NULL,
   p_tax_rate_id        IN   NUMBER,
   p_org_id             IN   NUMBER,
   p_ledger_id          IN   NUMBER,
   x_tax_account_ccid   OUT  NOCOPY   NUMBER,
   x_return_status      OUT  NOCOPY   VARCHAR2,
   x_msg_out            OUT  NOCOPY   VARCHAR2
);


PROCEDURE get_tax_rate_id
(   p_api_version       IN   NUMBER  DEFAULT NULL,
    p_org_id            IN   NUMBER,
    p_le_id             IN   NUMBER,
    p_tax_rate_code     IN   VARCHAR2,
    p_trx_date          IN   DATE,
    p_tax_type_code     IN   OUT NOCOPY   VARCHAR2,
    x_tax_rate_id       OUT      NOCOPY   NUMBER,
    x_return_status     OUT      NOCOPY   VARCHAR2,
    x_msg_out           OUT      NOCOPY   VARCHAR2
);


PROCEDURE get_tax_code
(   p_api_version       IN   NUMBER  DEFAULT NULL,
    p_org_id            IN   NUMBER,
    p_tax_type_code     IN   VARCHAR2,
    p_tax_rate_id       IN   NUMBER,
    x_tax_rate_code     OUT  NOCOPY   VARCHAR2,
    x_return_status     OUT  NOCOPY   VARCHAR2,
    x_msg_out           OUT  NOCOPY   VARCHAR2
);


PROCEDURE get_tax_rate_code
(   p_api_version       IN   NUMBER  DEFAULT NULL,
    p_tax_type_code     IN   VARCHAR2,
    p_tax_rate_id       IN   NUMBER,
    x_tax_rate_code     OUT  NOCOPY   VARCHAR2,
    x_return_status     OUT  NOCOPY   VARCHAR2,
    x_msg_out           OUT  NOCOPY   VARCHAR2
);

PROCEDURE get_rounding_rule_code
(   p_api_version      IN    NUMBER DEFAULT NULL,
    p_ledger_id        IN    NUMBER,
    p_org_id           IN    NUMBER,
    p_le_id            IN    NUMBER,
    p_tax_class        IN    VARCHAR2,
    x_rounding_rule_code  OUT NOCOPY VARCHAR2,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_out             OUT NOCOPY VARCHAR2
);


PROCEDURE get_precision_mau
(  p_api_version IN  NUMBER DEFAULT NULL,
   p_ledger_id   IN  NUMBER,
   p_org_id      IN  NUMBER,
   p_le_id       IN  NUMBER,
   x_precision   OUT NOCOPY  NUMBER,
   x_mau         OUT NOCOPY  NUMBER,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_out        OUT NOCOPY VARCHAR2
);


PROCEDURE get_default_tax_include_flag
(
   p_api_version        IN NUMBER  DEFAULT NULL,
   p_ledger_id          IN NUMBER,
   p_org_id             IN NUMBER,
   p_le_id              IN NUMBER,
   p_account_value      IN VARCHAR2,
   p_tax_type_code      IN VARCHAR2,
   x_include_tax_flag   OUT NOCOPY  VARCHAR2,
   x_return_status      OUT NOCOPY  VARCHAR2,
   x_msg_out            OUT NOCOPY  VARCHAR2
);

PROCEDURE get_ledger_controls
(  p_api_version IN  NUMBER DEFAULT NULL,
   p_ledger_id   IN  NUMBER,
   p_org_id      IN  NUMBER,
   p_le_id       IN  NUMBER,
   x_calculation_level_code   OUT NOCOPY  VARCHAR2,
   x_tax_mau                  OUT NOCOPY  NUMBER,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_out                  OUT NOCOPY VARCHAR2
);


END zx_gl_tax_options_pkg;

 

/
