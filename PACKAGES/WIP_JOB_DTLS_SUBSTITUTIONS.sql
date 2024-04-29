--------------------------------------------------------
--  DDL for Package WIP_JOB_DTLS_SUBSTITUTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_JOB_DTLS_SUBSTITUTIONS" AUTHID CURRENT_USER AS
/* $Header: wipjdsts.pls 120.2.12000000.1 2007/01/18 22:16:39 appldev ship $ */


Procedure Delete_Resource (p_group_id           number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_err_code      out NOCOPY     varchar2,
                        p_err_msg       out NOCOPY     varchar2);

Procedure Add_Resource (p_group_id              number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_err_code      out NOCOPY varchar2,
                        p_err_msg       out NOCOPY varchar2);


Procedure Change_Resource (p_group_id           number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_err_code      out NOCOPY varchar2,
                        p_err_msg       out NOCOPY varchar2);


Procedure Delete_Resource_Instance (p_group_id           number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_substitution_type     number,
                        p_err_code      out NOCOPY     varchar2,
                        p_err_msg       out NOCOPY     varchar2);

Procedure Add_Resource_Instance (p_group_id              number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_err_code      out NOCOPY varchar2,
                        p_err_msg       out NOCOPY varchar2);


Procedure Change_Resource_Instance (p_group_id           number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_err_code      out NOCOPY varchar2,
                        p_err_msg       out NOCOPY varchar2);

Procedure Delete_Sub_Resource (p_group_id              number,
                               p_wip_entity_id         number,
                               p_organization_id       number,
                               p_err_code       out NOCOPY    varchar2,
                               p_err_msg        out NOCOPY    varchar2);

Procedure Add_Sub_Resource (p_group_id              number,
                            p_wip_entity_id         number,
                            p_organization_id       number,
                            p_err_code      out NOCOPY varchar2,
                            p_err_msg       out NOCOPY varchar2);



Procedure Change_Sub_Resource (p_group_id              number,
                               p_wip_entity_id         number,
                               p_organization_id       number,
                               p_err_code          out NOCOPY varchar2,
                               p_err_msg           out NOCOPY varchar2);


Procedure Delete_Requirement (p_group_id           number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_err_code      out NOCOPY varchar2,
                        p_err_msg       out NOCOPY varchar2);


Procedure Add_Requirement (p_group_id           number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_err_code      out NOCOPY varchar2,
                        p_err_msg       out NOCOPY varchar2);


Procedure Change_Requirement (p_group_id           number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_err_code      out NOCOPY varchar2,
                        p_err_msg       out NOCOPY varchar2);

Procedure Add_Operation (p_group_id             in  number,
                         p_wip_entity_id        in  number,
                         p_organization_id      in  number,
                         x_err_code             out NOCOPY varchar2,
                         x_err_msg              out NOCOPY varchar2 ,
                         x_return_status        out NOCOPY varchar2);

Procedure Change_Operation (p_group_id          in  number,
                            p_wip_entity_id     in  number,
                            p_organization_id   in  number,
                            x_err_code          out NOCOPY varchar2,
                            x_err_msg           out NOCOPY varchar2,
                            x_return_status     out NOCOPY varchar2);

Procedure Verify_Operation (p_group_id          in  number,
                            p_wip_entity_id     in  number,
                            p_organization_id   in  number,
                            x_err_code          out NOCOPY varchar2,
                            x_err_msg           out NOCOPY varchar2,
                            x_return_status     out NOCOPY varchar2);

Procedure Delete_Resource_Usage(p_wip_entity_id number,
                                p_organization_id number,
                                p_operation_seq_num number,
                                p_resource_seq_num number,
                                x_err_code out NOCOPY varchar2,
                                x_err_msg out NOCOPY varchar2);

Procedure Substitution_Res_Usages( p_group_id           in number,
                                   p_wip_entity_id      in number,
                                   p_organization_id    in number,
                                   x_err_code           out NOCOPY varchar2,
                                   x_err_msg            out NOCOPY varchar2,
                                   x_return_status      out NOCOPY varchar2);

Procedure Sub_Usage (p_group_id                 in number,
                     p_wip_entity_id            in number,
                     p_organization_id          in number,
                     p_operation_seq_num        in number,
                     p_resource_seq_num         in number,
                     x_err_code                 out NOCOPY varchar2,
                     x_err_msg                  out NOCOPY varchar2,
                     x_return_status            out NOCOPY varchar2);

Procedure Add_Default_Usage(p_wip_entity_id             number,
                            p_organization_id           number,
                            p_operation_seq_num         number,
                            p_resource_seq_num          number);


Function Num_Of_Usage(p_group_id                number,  /* Fix for bug#3636378 */
                      p_wip_entity_id           number,
                      p_organization_id         number,
                      p_operation_seq_num       number,
                      p_resource_seq_num        number) return number;

Procedure Delete_Op_Link (p_group_id           in number,
                          p_wip_entity_id      in number,
                          p_organization_id    in number,
                          p_err_code          out NOCOPY varchar2,
                          p_err_msg           out NOCOPY varchar2);

Procedure Add_Op_Link (p_group_id           in number,
                       p_wip_entity_id      in number,
                       p_organization_id    in number,
                       p_err_code          out NOCOPY varchar2,
                       p_err_msg           out NOCOPY varchar2);

Procedure Add_Serial_Association(p_group_id         in number,
                                 p_wip_entity_id    in number,
                                 p_organization_id  in number,
                                 x_err_code        out NOCOPY varchar2,
                                 x_err_msg         out NOCOPY varchar2,
                                 x_return_status       out NOCOPY varchar2);

Procedure Change_Serial_Association(p_group_id         in number,
                                    p_wip_entity_id    in number,
                                    p_organization_id  in number,
                                    x_err_code        out NOCOPY varchar2,
                                    x_err_msg         out NOCOPY varchar2,
                                    x_return_status       out NOCOPY varchar2);


Procedure Delete_Serial_Association(p_group_id         in number,
                                    p_wip_entity_id    in number,
                                    p_organization_id  in number,
                                    x_err_code        out NOCOPY varchar2,
                                    x_err_msg         out NOCOPY varchar2,
                                    x_return_status       out NOCOPY varchar2);

Procedure Default_Serial_Associations(p_rowid            in rowid,
                                      p_wip_entity_id    in number,
                                      p_organization_id  in number,
                                      x_err_msg         out NOCOPY varchar2,
                                      x_return_status   out NOCOPY varchar2);

Procedure Update_Cumulative_Time (
                              p_wip_entity_id           in number,
                              p_operation_seq_num       in number,
                              p_resource_seq_num        in number);

END WIP_JOB_DTLS_SUBSTITUTIONS;

 

/
