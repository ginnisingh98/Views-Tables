--------------------------------------------------------
--  DDL for Package PA_OBJECT_RELATIONSHIPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_OBJECT_RELATIONSHIPS_PKG" AUTHID CURRENT_USER as
/* $Header: PAOBRPKS.pls 120.1 2005/08/19 16:36:28 mwasowic noship $ */

procedure INSERT_ROW
(                       p_user_id               IN      NUMBER,
                  	p_object_type_from	IN	VARCHAR2,
			p_object_id_from1	IN	NUMBER,
			p_object_id_from2	IN	NUMBER,
			p_object_id_from3	IN	NUMBER,
			p_object_id_from4	IN	NUMBER,
			p_object_id_from5	IN	NUMBER,
			p_object_type_to	IN	VARCHAR2,
			p_object_id_to1		IN	NUMBER,
			p_object_id_to2 	IN	NUMBER,
			p_object_id_to3		IN	NUMBER,
			p_object_id_to4		IN	NUMBER,
			p_object_id_to5		IN	NUMBER,
			p_relationship_type	IN	VARCHAR2,
			p_relationship_subtype	IN	VARCHAR2,
			p_lag_day 		IN	NUMBER,
			p_imported_lag		IN	VARCHAR2,
			p_priority		IN	VARCHAR2,
                        p_pm_product_code       IN      VARCHAR2,
                        p_weighting_percentage  IN      NUMBER := 0,
                   --FPM bug 3301192
                        p_comments              IN      VARCHAR2 := NULL,
                        p_status_code           IN      VARCHAR2 := NULL,
                   --end FPM bug 3301192
			x_object_relationship_id OUT	NOCOPY NUMBER, --File.Sql.39 bug 4440895
			x_return_status		 OUT	NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

procedure UPDATE_ROW
(       p_user_id               IN      NUMBER,
        p_object_relationship_id        IN      NUMBER,
        p_relationship_type     IN      VARCHAR2,
        p_relationship_subtype  IN      VARCHAR2,
        p_lag_day               IN      NUMBER,
        p_priority              IN      VARCHAR2,
        p_pm_product_code       IN      VARCHAR2,
	p_weighting_percentage  IN      NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  --FPM bug 3301192
        p_comments              IN      VARCHAR2 := NULL,
        p_status_code           IN      VARCHAR2 := NULL,
  --end FPM bug 3301192
        p_record_version_number IN      NUMBER,
        x_return_status         OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


procedure DELETE_ROW
(	p_object_relationship_id	IN	NUMBER,
        p_object_type_from      IN      VARCHAR2,
        p_object_id_from1       IN      NUMBER,
        p_object_id_from2       IN      NUMBER,
        p_object_id_from3       IN      NUMBER,
        p_object_id_from4       IN      NUMBER,
        p_object_id_from5       IN      NUMBER,
        p_object_type_to        IN      VARCHAR2,
        p_object_id_to1         IN      NUMBER,
        p_object_id_to2         IN      NUMBER,
        p_object_id_to3         IN      NUMBER,
        p_object_id_to4         IN      NUMBER,
        p_object_id_to5         IN      NUMBER,
	p_record_version_number	IN	NUMBER,
        p_pm_product_code       IN      VARCHAR2,
	x_return_status	        OUT	NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

END PA_OBJECT_RELATIONSHIPS_PKG;


 

/
