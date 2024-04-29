--------------------------------------------------------
--  DDL for Package PA_AGREEMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_AGREEMENT_PVT" AUTHID CURRENT_USER as
/*$Header: PAAFAPVS.pls 120.5.12010000.2 2008/09/04 22:25:14 jngeorge ship $*/

PROCEDURE convert_ag_ref_to_id
(p_pm_agreement_reference  	IN 	VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  /* Bug 1851096 */
,p_af_agreement_id  	IN 	NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  /* Bug 1851096 */
,p_out_agreement_id 	OUT 	NOCOPY NUMBER /*File.sql.39*/
,p_return_status    	OUT 	NOCOPY VARCHAR2 /*File.sql.39*/
 );

PROCEDURE Convert_fu_ref_to_id
(p_pm_funding_reference  	IN 	VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  /* Bug 1851096 */
,p_af_funding_id  	IN 	NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  /* Bug 1851096 */
,p_out_funding_id 	OUT 	NOCOPY NUMBER /*File.sql.39*/
,p_return_status    	OUT 	NOCOPY VARCHAR2 /*File.sql.39*/
 );

FUNCTION fetch_agreement_id
(p_pm_agreement_reference IN VARCHAR2 )
RETURN NUMBER;

FUNCTION fetch_funding_id
(p_pm_funding_reference IN VARCHAR2 )
RETURN NUMBER;

/* Modified for MCB2 change */
FUNCTION check_create_agreement_ok
(p_pm_agreement_reference	IN 	VARCHAR2
 ,p_customer_id			IN	NUMBER
 ,p_agreement_type		IN 	VARCHAR2
 ,p_agreement_num		IN 	VARCHAR2
 ,p_term_id			IN	NUMBER
 ,p_template_flag		IN	VARCHAR2
 ,p_revenue_limit_flag		IN	VARCHAR2
 ,p_owned_by_person_id          IN      NUMBER
 ,p_owning_organization_id      IN      NUMBER default null
 ,p_agreement_currency_code     IN      VARCHAR2 default null
 ,p_invoice_limit_flag          IN      VARCHAR2 default null
/*Federal*/
 ,p_start_date                  IN      DATE  DEFAULT NULL
 ,p_end_date                    IN      DATE  DEFAULT NULL
 ,p_advance_required            IN      VARCHAR2 DEFAULT NULL
 ,p_billing_sequence            IN      Number   DEFAULT NULL)
 RETURN VARCHAR2;

/* Modified for MCB2 change */
FUNCTION check_update_agreement_ok
(p_pm_agreement_reference       IN       VARCHAR2
,p_agreement_id                 IN       NUMBER
,p_funding_id		        IN       NUMBER
,p_customer_id			IN OUT NOCOPY	NUMBER /*Bug 6602451*/
,p_agreement_type		IN OUT NOCOPY 	VARCHAR2 /*Bug 6602451*/
,p_term_id			IN OUT NOCOPY	NUMBER /*Bug 6602451*/
,p_template_flag		IN	VARCHAR2
,p_revenue_limit_flag		IN OUT NOCOPY	VARCHAR2 /*Bug 6602451*/
,p_owned_by_person_id          IN OUT NOCOPY     NUMBER /*Bug 6602451*/
,p_owning_organization_id      IN OUT NOCOPY     NUMBER /*Bug 6602451*/
,p_agreement_currency_code     IN OUT NOCOPY     VARCHAR2 /*Bug 6602451*/
,p_invoice_limit_flag          IN OUT NOCOPY     VARCHAR2 /*Bug 6602451*/
/*Federal*/
,p_start_date                   IN      DATE  DEFAULT NULL
,p_end_date                     IN      DATE  DEFAULT NULL
,p_advance_required             IN      VARCHAR2 DEFAULT NULL
,p_billing_sequence             IN      Number   DEFAULT NULL
,p_amount                       IN      NUMBER   DEFAULT NULL)

RETURN VARCHAR2;

FUNCTION check_delete_agreement_ok
(p_agreement_id 		IN 	NUMBER
,p_pm_agreement_reference	IN	VARCHAR2)
RETURN VARCHAR2;

/* Added for Bug 2403652 */

FUNCTION check_funding_category
( p_project_id                  IN      NUMBER
 ,p_task_id                     IN      NUMBER
 ,p_agreement_id                IN      NUMBER
 ,p_pm_funding_reference        IN      VARCHAR2
 ,p_funding_category            IN      VARCHAR2)
RETURN VARCHAR2;


/* Modified for MCB2 change */
FUNCTION check_add_funding_ok
(p_project_id			IN	NUMBER
 ,p_task_id			IN	NUMBER
 ,p_agreement_id                IN	NUMBER
 ,p_pm_funding_reference   	IN 	VARCHAR2
 ,p_funding_amt			IN	NUMBER
 ,p_customer_id                 IN      NUMBER
 ,p_project_rate_type           IN      VARCHAR2 default null
 ,p_project_rate_date           IN      DATE     default null
 ,p_project_exchange_rate       IN      NUMBER   default null
 ,p_projfunc_rate_type          IN      VARCHAR2 default null
 ,p_projfunc_rate_date          IN      DATE     default null
 ,p_projfunc_exchange_rate      IN      NUMBER   default null
 ,p_calling_context             IN      VARCHAR2 default null)-- Bug 6600563
 RETURN VARCHAR2;
 -- Nikhil added to validate the funding amount

/* Modified for MCB2 change */
FUNCTION check_update_funding_ok
(p_project_id			IN	NUMBER
,p_task_id			IN	NUMBER
,p_agreement_id                	IN	NUMBER
,p_customer_id			IN 	NUMBER
,p_pm_funding_reference   	IN 	VARCHAR2
,p_funding_id			IN	NUMBER
,p_funding_amt                 IN      NUMBER
,p_project_rate_type           IN      VARCHAR2 default null
,p_project_rate_date           IN      DATE     default null
,p_project_exchange_rate       IN      NUMBER   default null
,p_projfunc_rate_type          IN      VARCHAR2 default null
,p_projfunc_rate_date          IN      DATE     default null
,p_projfunc_exchange_rate      IN      NUMBER   default null)
RETURN VARCHAR2;

FUNCTION check_delete_funding_ok
(p_agreement_id			IN	NUMBER
,p_funding_id			IN	NUMBER
,p_pm_funding_reference		IN 	VARCHAR2)
RETURN VARCHAR2;

PROCEDURE validate_flex_fields
(p_desc_flex_name        IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,p_attribute_category    IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,p_attribute1            IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,p_attribute2            IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,p_attribute3            IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,p_attribute4            IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,p_attribute5            IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,p_attribute6            IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,p_attribute7            IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,p_attribute8            IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,p_attribute9            IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,p_attribute10           IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
/*Federal*/
,p_attribute11           IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,p_attribute12           IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,p_attribute13           IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,p_attribute14           IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,p_attribute15           IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,p_attribute16           IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,p_attribute17           IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,p_attribute18           IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,p_attribute19           IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,p_attribute20           IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,p_attribute21           IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,p_attribute22           IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,p_attribute23           IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,p_attribute24           IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,p_attribute25           IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR

,p_return_msg            OUT NOCOPY VARCHAR2 /*File.sql.39*/
,p_validate_status       OUT NOCOPY VARCHAR2 /*File.sql.39*/
);

FUNCTION check_yes_no
(p_val VARCHAR2)
RETURN VARCHAR2;

FUNCTION check_add_update
(p_funding_reference VARCHAR2)
RETURN VARCHAR2;

FUNCTION validate_funding_amt
(p_funding_amt	NUMBER
,p_agreement_id	NUMBER
,p_operation_flag VARCHAR2
,p_funding_id	NUMBER DEFAULT NULL
,p_pm_funding_reference VARCHAR2  )
RETURN VARCHAR2;


END PA_AGREEMENT_PVT;

/
