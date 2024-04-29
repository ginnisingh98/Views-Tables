--------------------------------------------------------
--  DDL for Package QP_COUPON_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_COUPON_PVT" AUTHID CURRENT_USER AS
/* $Header: QPXVCPNS.pls 120.0.12000000.1 2007/01/17 22:34:34 appldev ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_COUPON_PVT';

G_COUPON_ISSUE_LINE_TYPE   CONSTANT VARCHAR2(30) := 'CIE';
G_COUPON_QUALIFIER         CONSTANT VARCHAR2(30) := 'QUALIFIER_ATTRIBUTE3';
G_COUPON_GRP_TYPE          CONSTANT VARCHAR2(30) := 'COUPON';

-- Procedure Insert_Coupon creates a record in QP_COUPONS table
PROCEDURE Insert_Coupon(
    p_issued_by_modifier_id      IN NUMBER
,   p_expiration_period_start_date                 IN DATE    := NULL
,   p_expiration_date            IN DATE    := NULL
,   p_number_expiration_periods  IN NUMBER  := NULL
,   p_expiration_period_uom_code IN VARCHAR2
,   p_user_def_coupon_number     IN VARCHAR2
,   p_pricing_effective_date     IN DATE
,   x_coupon_id                  OUT NOCOPY NUMBER
,   x_coupon_number              OUT NOCOPY VARCHAR2
,   x_return_status              OUT NOCOPY VARCHAR2
,   x_return_status_txt              OUT NOCOPY VARCHAR2
);

-- Procedure Create_Coupon_Qualifier creates a record in QP_QUALIFIERS table to say that
-- if your order quotes this coupon number, you can use the benefits in the coupon
PROCEDURE Create_Coupon_Qualifier(
    p_list_line_id               IN NUMBER
,   p_coupon_id                  IN NUMBER
,   x_return_status         OUT NOCOPY VARCHAR2
,   x_return_status_txt          OUT NOCOPY VARCHAR2
);

PROCEDURE Mark_Coupon_Redeemed(
    p_coupon_number              IN VARCHAR2
,   p_pricing_effective_date     IN DATE
,   x_return_status         OUT NOCOPY VARCHAR2
,   x_return_status_txt          OUT NOCOPY VARCHAR2
);

-- This will be obsolete, please use the overloaded version with
-- p_coupon_number as argument
PROCEDURE Mark_Coupon_Unredeemed(
    p_coupon_id                  IN NUMBER
,   x_return_status         OUT NOCOPY VARCHAR2
,   x_return_status_txt          OUT NOCOPY VARCHAR2
);

PROCEDURE Mark_Coupon_Unredeemed(
    p_coupon_number         IN VARCHAR2
,   x_return_status         OUT NOCOPY VARCHAR2
,   x_return_status_txt          OUT NOCOPY VARCHAR2
);

-- Procedure Delete_Coupon deletes the coupon
PROCEDURE Delete_Coupon(
    p_coupon_number                   IN VARCHAR2
,   x_return_status         OUT NOCOPY VARCHAR2
,   x_return_status_txt          OUT NOCOPY VARCHAR2
);

-- Procedure Purge_Coupon purges all redeemed and expired coupons
PROCEDURE Purge_Coupon(
    x_return_status         OUT NOCOPY VARCHAR2
,   x_return_status_txt          OUT NOCOPY VARCHAR2
);

-- Main Procedure to Process Coupon Issue lines
PROCEDURE Process_Coupon_Issue(
    p_line_detail_index            IN NUMBER
,   p_pricing_phase_id      IN NUMBER
,   p_line_quantity         IN NUMBER
,   p_simulation_flag       IN VARCHAR2
,   x_return_status         OUT NOCOPY VARCHAR2
,   x_return_status_txt          OUT NOCOPY VARCHAR2
);

-- Main Procedure to Redeem all coupons processed
PROCEDURE Redeem_Coupons(
    p_simulation_flag       IN VARCHAR2
,   x_return_status         OUT NOCOPY VARCHAR2
,   x_return_status_txt          OUT NOCOPY VARCHAR2
);

PROCEDURE Set_Expiration_Dates(
    p_expiration_period_start_date   IN OUT NOCOPY DATE
,   p_expiration_period_end_date     IN OUT NOCOPY DATE
,   p_number_expiration_periods      IN NUMBER
,   p_expiration_period_uom_code     IN Varchar2
,   p_pricing_effective_date         IN DATE
,   x_return_status         OUT NOCOPY VARCHAR2
,   x_return_status_txt          OUT NOCOPY VARCHAR2
);
END QP_COUPON_PVT;

 

/
