--------------------------------------------------------
--  DDL for Package PAY_FUNCTIONAL_USAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FUNCTIONAL_USAGES_PKG" AUTHID CURRENT_USER AS
-- $Header: pypfuapi.pkh 115.2 2002/12/11 15:13:48 exjones noship $
--
	PROCEDURE lock_row(
	  p_row_id            IN VARCHAR2,
	  p_usage_id          IN NUMBER,
	  p_area_id           IN NUMBER,
	  p_legislation_code  IN VARCHAR2,
	  p_business_group_id IN NUMBER,
	  p_payroll_id        IN NUMBER
	);
--
	PROCEDURE insert_row(
	  p_row_id            IN OUT NOCOPY VARCHAR2,
	  p_usage_id          IN OUT NOCOPY NUMBER,
	  p_area_id           IN NUMBER,
	  p_legislation_code  IN VARCHAR2,
	  p_business_group_id IN NUMBER,
	  p_payroll_id        IN NUMBER
	);
--
	PROCEDURE update_row(
	  p_row_id            IN VARCHAR2,
	  p_usage_id          IN NUMBER,
	  p_area_id           IN NUMBER,
	  p_legislation_code  IN VARCHAR2,
	  p_business_group_id IN NUMBER,
	  p_payroll_id        IN NUMBER
	);
--
	PROCEDURE delete_row(
	  p_row_id            IN VARCHAR2,
	  p_usage_id          IN NUMBER
	);
--
END pay_functional_usages_pkg;

 

/
