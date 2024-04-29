--------------------------------------------------------
--  DDL for Package PAY_US_TAXBAL_VIEW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_TAXBAL_VIEW_PKG" AUTHID CURRENT_USER as
/* $Header: pyustxbv.pkh 120.0.12010000.3 2009/05/14 10:38:17 sudedas ship $ */
--
-- Functions/Procedures
--
FUNCTION  us_tax_balance (p_tax_balance_category  in varchar2,
                          p_tax_type              in varchar2,
                          p_ee_or_er              in varchar2,
                          p_time_type             in varchar2,
                          p_asg_type              in varchar2,
                          p_gre_id_context        in number,
                          p_jd_context            in varchar2  DEFAULT NULL,
                          p_assignment_action_id  in number    DEFAULT NULL,
                          p_assignment_id         in number    DEFAULT NULL,
                          p_virtual_date          in date      DEFAULT NULL)
RETURN number;
--PRAGMA RESTRICT_REFERENCES(us_tax_balance, WNDS);
--
FUNCTION  us_tax_balance (p_tax_balance_category  in varchar2,
                          p_tax_type              in varchar2,
                          p_ee_or_er              in varchar2,
                          p_time_type             in varchar2,
                          p_asg_type              in varchar2,
                          p_gre_id_context        in number,
                          p_jd_context            in varchar2  DEFAULT NULL,
                          p_assignment_action_id  in number    DEFAULT NULL,
                          p_assignment_id         in number    DEFAULT NULL,
                          p_virtual_date          in date      DEFAULT NULL,
                          p_payroll_action_id     in number)
RETURN number;
--PRAGMA RESTRICT_REFERENCES(us_tax_balance, WNDS);
--
-- "_vm" wrapper function that calls us_tax_balance with asg_type param
-- derived from view_mode context stored in pkg global by set_view_mode
FUNCTION  us_tax_balance_vm (p_tax_balance_category  in varchar2,
                          p_tax_type              in varchar2,
                          p_ee_or_er              in varchar2,
                          p_time_type             in varchar2,
                          p_gre_id_context        in number,
                          p_jd_context            in varchar2  DEFAULT NULL,
                          p_assignment_action_id  in number    DEFAULT NULL,
                          p_assignment_id         in number    DEFAULT NULL,
                          p_virtual_date          in date      DEFAULT NULL,
                          p_payroll_action_id     in number)
RETURN number;
--PRAGMA RESTRICT_REFERENCES(us_tax_balance_vm, WNDS);
--
FUNCTION us_named_balance
                         (p_balance_name          varchar2,
                          p_dimension_suffix      varchar2,
                          p_assignment_action_id  number    DEFAULT NULL,
                          p_assignment_id         number    DEFAULT NULL,
                          p_virtual_date          date      DEFAULT NULL,
                          p_asg_type              varchar2  DEFAULT NULL,
                          p_gre_id                number    DEFAULT NULL,
                          p_business_group_id     number		DEFAULT NULL,
                          p_jurisdiction_code     varchar2  DEFAULT NULL)
RETURN number;
--PRAGMA RESTRICT_REFERENCES(us_named_balance, WNDS);
--
FUNCTION us_named_balance_vm
                         (p_balance_name          varchar2,
                          p_dimension_suffix      varchar2,
                          p_assignment_action_id  number    DEFAULT NULL,
                          p_assignment_id         number    DEFAULT NULL,
                          p_virtual_date          date      DEFAULT NULL,
                          p_gre_id                number    DEFAULT NULL,
                          p_business_group_id     number	DEFAULT NULL,
                          p_jurisdiction_code     varchar2  DEFAULT NULL,
                          p_classification_name   varchar2  DEFAULT NULL,
                          p_accrued_dimension     varchar2  DEFAULT NULL,
                          p_source_id             number    DEFAULT NULL,
                          p_ele_typ_id            number    DEFAULT NULL)
RETURN number;
--
--PRAGMA RESTRICT_REFERENCES(us_named_balance_vm, WNDS);
--
--
FUNCTION payments_balance_required(p_assignment_action_id NUMBER)
RETURN boolean;
--
PRAGMA RESTRICT_REFERENCES(payments_balance_required, WNDS);
--
procedure us_gp_multiple_gre_ytd (p_tax_unit_id    IN  NUMBER,
                               p_effective_date IN  DATE,
                               p_balance_name1  IN  VARCHAR2 DEFAULT NULL,
                               p_balance_name2  IN  VARCHAR2 DEFAULT NULL,
                               p_balance_name3  IN  VARCHAR2 DEFAULT NULL,
                               p_balance_name4  IN  VARCHAR2 DEFAULT NULL,
                               p_balance_name5  IN  VARCHAR2 DEFAULT NULL,
                               p_balance_name6  IN  VARCHAR2 DEFAULT NULL,
                               p_balance_name7  IN  VARCHAR2 DEFAULT NULL,
                               p_balance_name8  IN  VARCHAR2 DEFAULT NULL,
                               p_balance_name9  IN  VARCHAR2 DEFAULT NULL,
                               p_balance_name10 IN  VARCHAR2 DEFAULT NULL,
                               p_value1         OUT NOCOPY NUMBER,
                               p_value2         OUT NOCOPY NUMBER,
                               p_value3         OUT NOCOPY NUMBER,
                               p_value4         OUT NOCOPY NUMBER,
                               p_value5         OUT NOCOPY NUMBER,
                               p_value6         OUT NOCOPY NUMBER,
                               p_value7         OUT NOCOPY NUMBER,
                               p_value8         OUT NOCOPY NUMBER,
                               p_value9         OUT NOCOPY NUMBER,
                               p_value10        OUT NOCOPY NUMBER);
--
PRAGMA RESTRICT_REFERENCES(us_gp_multiple_gre_ytd, WNDS);
--
procedure us_gp_multiple_gre_qtd (p_tax_unit_id    IN  NUMBER,
                               p_effective_date IN  DATE,
                               p_balance_name1  IN  VARCHAR2 DEFAULT NULL,
                               p_balance_name2  IN  VARCHAR2 DEFAULT NULL,
                               p_balance_name3  IN  VARCHAR2 DEFAULT NULL,
                               p_balance_name4  IN  VARCHAR2 DEFAULT NULL,
                               p_balance_name5  IN  VARCHAR2 DEFAULT NULL,
                               p_balance_name6  IN  VARCHAR2 DEFAULT NULL,
                               p_balance_name7  IN  VARCHAR2 DEFAULT NULL,
                               p_balance_name8  IN  VARCHAR2 DEFAULT NULL,
                               p_balance_name9  IN  VARCHAR2 DEFAULT NULL,
                               p_balance_name10 IN  VARCHAR2 DEFAULT NULL,
                               p_value1         OUT NOCOPY NUMBER,
                               p_value2         OUT NOCOPY NUMBER,
                               p_value3         OUT NOCOPY NUMBER,
                               p_value4         OUT NOCOPY NUMBER,
                               p_value5         OUT NOCOPY NUMBER,
                               p_value6         OUT NOCOPY NUMBER,
                               p_value7         OUT NOCOPY NUMBER,
                               p_value8         OUT NOCOPY NUMBER,
                               p_value9         OUT NOCOPY NUMBER,
                               p_value10        OUT NOCOPY NUMBER);
--
procedure us_gp_multiple_gre_qtd (p_tax_unit_id    IN  NUMBER,
                               p_effective_date IN  DATE,
                               p_balance_name1  IN  VARCHAR2 DEFAULT NULL,
                               p_balance_name2  IN  VARCHAR2 DEFAULT NULL,
                               p_balance_name3  IN  VARCHAR2 DEFAULT NULL,
                               p_balance_name4  IN  VARCHAR2 DEFAULT NULL,
                               p_balance_name5  IN  VARCHAR2 DEFAULT NULL,
                               p_balance_name6  IN  VARCHAR2 DEFAULT NULL,
                               p_balance_name7  IN  VARCHAR2 DEFAULT NULL,
                               p_balance_name8  IN  VARCHAR2 DEFAULT NULL,
                               p_balance_name9  IN  VARCHAR2 DEFAULT NULL,
                               p_balance_name10 IN  VARCHAR2 DEFAULT NULL,
                               p_balance_name11 IN  VARCHAR2 DEFAULT NULL,
                               p_balance_name12 IN  VARCHAR2 DEFAULT NULL,
                               p_value1         OUT NOCOPY NUMBER,
                               p_value2         OUT NOCOPY NUMBER,
                               p_value3         OUT NOCOPY NUMBER,
                               p_value4         OUT NOCOPY NUMBER,
                               p_value5         OUT NOCOPY NUMBER,
                               p_value6         OUT NOCOPY NUMBER,
                               p_value7         OUT NOCOPY NUMBER,
                               p_value8         OUT NOCOPY NUMBER,
                               p_value9         OUT NOCOPY NUMBER,
                               p_value10        OUT NOCOPY NUMBER,
                               p_value11        OUT NOCOPY NUMBER,
                               p_value12        OUT NOCOPY NUMBER);
--
PRAGMA RESTRICT_REFERENCES(us_gp_multiple_gre_qtd, WNDS);
--
PROCEDURE us_gp_subject_to_tax_gre_ytd (p_balance_name1   IN     VARCHAR2 DEFAULT NULL,
                                        p_balance_name2   IN     VARCHAR2 DEFAULT NULL,
                                        p_balance_name3   IN     VARCHAR2 DEFAULT NULL,
                                        p_balance_name4   IN     VARCHAR2 DEFAULT NULL,
                                        p_balance_name5   IN     VARCHAR2 DEFAULT NULL,
                                        p_effective_date  IN DATE,
                                        p_tax_unit_id     IN NUMBER,
                                        p_value1          OUT NOCOPY NUMBER,
                                        p_value2          OUT NOCOPY NUMBER,
                                        p_value3          OUT NOCOPY NUMBER,
                                        p_value4          OUT NOCOPY NUMBER,
                                        p_value5          OUT NOCOPY NUMBER);
--
PRAGMA RESTRICT_REFERENCES(us_gp_subject_to_tax_gre_ytd, WNDS);
--
PROCEDURE us_gp_subject_to_tax_gre_qtd (p_balance_name1   IN     VARCHAR2 DEFAULT NULL,
                                        p_balance_name2   IN     VARCHAR2 DEFAULT NULL,
                                        p_balance_name3   IN     VARCHAR2 DEFAULT NULL,
                                        p_balance_name4   IN     VARCHAR2 DEFAULT NULL,
                                        p_balance_name5   IN     VARCHAR2 DEFAULT NULL,
                                        p_effective_date  IN DATE,
                                        p_tax_unit_id     IN NUMBER,
                                        p_value1          OUT NOCOPY NUMBER,
                                        p_value2          OUT NOCOPY NUMBER,
                                        p_value3          OUT NOCOPY NUMBER,
                                        p_value4          OUT NOCOPY NUMBER,
                                        p_value5          OUT NOCOPY NUMBER);
--
PRAGMA RESTRICT_REFERENCES(us_gp_subject_to_tax_gre_qtd, WNDS);
--
PROCEDURE us_gp_gre_jd_ytd (p_balance_name1   IN     VARCHAR2 DEFAULT NULL,
                            p_balance_name2   IN     VARCHAR2 DEFAULT NULL,
                            p_balance_name3   IN     VARCHAR2 DEFAULT NULL,
                            p_balance_name4   IN     VARCHAR2 DEFAULT NULL,
                            p_balance_name5   IN     VARCHAR2 DEFAULT NULL,
                            p_balance_name6   IN     VARCHAR2 DEFAULT NULL,
                            p_balance_name7   IN     VARCHAR2 DEFAULT NULL,
                            p_effective_date  IN     DATE,
                            p_tax_unit_id     IN     NUMBER,
                            p_state_code      IN     VARCHAR2,
                            p_value1             OUT NOCOPY NUMBER,
                            p_value2             OUT NOCOPY NUMBER,
                            p_value3             OUT NOCOPY NUMBER,
                            p_value4             OUT NOCOPY NUMBER,
                            p_value5             OUT NOCOPY NUMBER,
                            p_value6             OUT NOCOPY NUMBER,
                            p_value7             OUT NOCOPY NUMBER);
--
PRAGMA RESTRICT_REFERENCES(us_gp_gre_jd_ytd,WNDS);
--
PROCEDURE us_gp_gre_jd_qtd (p_balance_name1   IN     VARCHAR2 DEFAULT NULL,
                            p_balance_name2   IN     VARCHAR2 DEFAULT NULL,
                            p_balance_name3   IN     VARCHAR2 DEFAULT NULL,
                            p_balance_name4   IN     VARCHAR2 DEFAULT NULL,
                            p_balance_name5   IN     VARCHAR2 DEFAULT NULL,
                            p_balance_name6   IN     VARCHAR2 DEFAULT NULL,
                            p_balance_name7   IN     VARCHAR2 DEFAULT NULL,
                            p_effective_date  IN     DATE,
                            p_tax_unit_id     IN     NUMBER,
                            p_state_code      IN     VARCHAR2,
                            p_value1             OUT NOCOPY NUMBER,
                            p_value2             OUT NOCOPY NUMBER,
                            p_value3             OUT NOCOPY NUMBER,
                            p_value4             OUT NOCOPY NUMBER,
                            p_value5             OUT NOCOPY NUMBER,
                            p_value6             OUT NOCOPY NUMBER,
                            p_value7             OUT NOCOPY NUMBER);
--
PRAGMA RESTRICT_REFERENCES(us_gp_gre_jd_qtd,WNDS);
--
procedure us_gp_multiple_gre_mtd (p_tax_unit_id    IN  NUMBER,
                               p_effective_date IN  DATE,
                               p_balance_name1  IN  VARCHAR2 DEFAULT NULL,
                               p_balance_name2  IN  VARCHAR2 DEFAULT NULL,
                               p_balance_name3  IN  VARCHAR2 DEFAULT NULL,
                               p_balance_name4  IN  VARCHAR2 DEFAULT NULL,
                               p_balance_name5  IN  VARCHAR2 DEFAULT NULL,
                               p_balance_name6  IN  VARCHAR2 DEFAULT NULL,
                               p_balance_name7  IN  VARCHAR2 DEFAULT NULL,
                               p_balance_name8  IN  VARCHAR2 DEFAULT NULL,
                               p_balance_name9  IN  VARCHAR2 DEFAULT NULL,
                               p_balance_name10 IN  VARCHAR2 DEFAULT NULL,
                               p_value1         OUT NOCOPY NUMBER,
                               p_value2         OUT NOCOPY NUMBER,
                               p_value3         OUT NOCOPY NUMBER,
                               p_value4         OUT NOCOPY NUMBER,
                               p_value5         OUT NOCOPY NUMBER,
                               p_value6         OUT NOCOPY NUMBER,
                               p_value7         OUT NOCOPY NUMBER,
                               p_value8         OUT NOCOPY NUMBER,
                               p_value9         OUT NOCOPY NUMBER,
                               p_value10        OUT NOCOPY NUMBER);
--
PRAGMA RESTRICT_REFERENCES(us_gp_multiple_gre_mtd, WNDS);
--
procedure us_gp_multiple_gre_ctd (p_tax_unit_id    IN  NUMBER,
                               p_start_date     IN  DATE,
                               p_effective_date IN  DATE,
                               p_balance_name1  IN  VARCHAR2 DEFAULT NULL,
                               p_balance_name2  IN  VARCHAR2 DEFAULT NULL,
                               p_balance_name3  IN  VARCHAR2 DEFAULT NULL,
                               p_balance_name4  IN  VARCHAR2 DEFAULT NULL,
                               p_balance_name5  IN  VARCHAR2 DEFAULT NULL,
                               p_balance_name6  IN  VARCHAR2 DEFAULT NULL,
                               p_balance_name7  IN  VARCHAR2 DEFAULT NULL,
                               p_balance_name8  IN  VARCHAR2 DEFAULT NULL,
                               p_balance_name9  IN  VARCHAR2 DEFAULT NULL,
                               p_balance_name10 IN  VARCHAR2 DEFAULT NULL,
                               p_value1         OUT NOCOPY NUMBER,
                               p_value2         OUT NOCOPY NUMBER,
                               p_value3         OUT NOCOPY NUMBER,
                               p_value4         OUT NOCOPY NUMBER,
                               p_value5         OUT NOCOPY NUMBER,
                               p_value6         OUT NOCOPY NUMBER,
                               p_value7         OUT NOCOPY NUMBER,
                               p_value8         OUT NOCOPY NUMBER,
                               p_value9         OUT NOCOPY NUMBER,
                               p_value10        OUT NOCOPY NUMBER);
--
PRAGMA RESTRICT_REFERENCES(us_gp_multiple_gre_ctd, WNDS);
--
--
PROCEDURE us_gp_subject_to_tax_gre_mtd (p_balance_name1   IN     VARCHAR2 DEFAULT NULL,
                                        p_balance_name2   IN     VARCHAR2 DEFAULT NULL,
                                        p_balance_name3   IN     VARCHAR2 DEFAULT NULL,
                                        p_balance_name4   IN     VARCHAR2 DEFAULT NULL,
                                        p_balance_name5   IN     VARCHAR2 DEFAULT NULL,
                                        p_effective_date  IN DATE,
                                        p_tax_unit_id     IN NUMBER,
                                        p_value1          OUT NOCOPY NUMBER,
                                        p_value2          OUT NOCOPY NUMBER,
                                        p_value3          OUT NOCOPY NUMBER,
                                        p_value4          OUT NOCOPY NUMBER,
                                        p_value5          OUT NOCOPY NUMBER);
--
PRAGMA RESTRICT_REFERENCES(us_gp_subject_to_tax_gre_mtd, WNDS);
--
PROCEDURE us_gp_subject_to_tax_gre_ctd (p_balance_name1   IN     VARCHAR2 DEFAULT NULL,
                                        p_balance_name2   IN     VARCHAR2 DEFAULT NULL,
                                        p_balance_name3   IN     VARCHAR2 DEFAULT NULL,
                                        p_balance_name4   IN     VARCHAR2 DEFAULT NULL,
                                        p_balance_name5   IN     VARCHAR2 DEFAULT NULL,
                                        p_start_date      IN DATE,
                                        p_effective_date  IN DATE,
                                        p_tax_unit_id     IN NUMBER,
                                        p_value1          OUT NOCOPY NUMBER,
                                        p_value2          OUT NOCOPY NUMBER,
                                        p_value3          OUT NOCOPY NUMBER,
                                        p_value4          OUT NOCOPY NUMBER,
                                        p_value5          OUT NOCOPY NUMBER);
--
PRAGMA RESTRICT_REFERENCES(us_gp_subject_to_tax_gre_ctd, WNDS);
--
PROCEDURE us_gp_gre_jd_mtd (p_balance_name1   IN     VARCHAR2 DEFAULT NULL,
                            p_balance_name2   IN     VARCHAR2 DEFAULT NULL,
                            p_balance_name3   IN     VARCHAR2 DEFAULT NULL,
                            p_balance_name4   IN     VARCHAR2 DEFAULT NULL,
                            p_balance_name5   IN     VARCHAR2 DEFAULT NULL,
                            p_balance_name6   IN     VARCHAR2 DEFAULT NULL,
                            p_balance_name7   IN     VARCHAR2 DEFAULT NULL,
                            p_effective_date  IN     DATE,
                            p_tax_unit_id     IN     NUMBER,
                            p_state_code      IN     VARCHAR2,
                            p_value1             OUT NOCOPY NUMBER,
                            p_value2             OUT NOCOPY NUMBER,
                            p_value3             OUT NOCOPY NUMBER,
                            p_value4             OUT NOCOPY NUMBER,
                            p_value5             OUT NOCOPY NUMBER,
                            p_value6             OUT NOCOPY NUMBER,
                            p_value7             OUT NOCOPY NUMBER);
--
PRAGMA RESTRICT_REFERENCES(us_gp_gre_jd_mtd,WNDS);
--
PROCEDURE us_gp_gre_jd_ctd (p_balance_name1   IN     VARCHAR2 DEFAULT NULL,
                            p_balance_name2   IN     VARCHAR2 DEFAULT NULL,
                            p_balance_name3   IN     VARCHAR2 DEFAULT NULL,
                            p_balance_name4   IN     VARCHAR2 DEFAULT NULL,
                            p_balance_name5   IN     VARCHAR2 DEFAULT NULL,
                            p_balance_name6   IN     VARCHAR2 DEFAULT NULL,
                            p_balance_name7   IN     VARCHAR2 DEFAULT NULL,
                            p_start_date      IN     DATE,
                            p_effective_date  IN     DATE,
                            p_tax_unit_id     IN     NUMBER,
                            p_state_code      IN     VARCHAR2,
                            p_value1             OUT NOCOPY NUMBER,
                            p_value2             OUT NOCOPY NUMBER,
                            p_value3             OUT NOCOPY NUMBER,
                            p_value4             OUT NOCOPY NUMBER,
                            p_value5             OUT NOCOPY NUMBER,
                            p_value6             OUT NOCOPY NUMBER,
                            p_value7             OUT NOCOPY NUMBER);
--
PRAGMA RESTRICT_REFERENCES(us_gp_gre_jd_ctd,WNDS);
--
end pay_us_taxbal_view_pkg;

/
