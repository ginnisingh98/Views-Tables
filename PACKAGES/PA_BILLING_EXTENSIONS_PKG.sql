--------------------------------------------------------
--  DDL for Package PA_BILLING_EXTENSIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_BILLING_EXTENSIONS_PKG" AUTHID CURRENT_USER as
/* $Header: PAXIBEXS.pls 120.1 2005/08/19 17:13:53 mwasowic noship $ */
--
  procedure check_unique_name ( x_return_status  IN OUT NOCOPY number, --File.Sql.39 bug 4440895
                                x_rowid          IN     varchar2,
                                x_name           IN     varchar2 );
--
  procedure check_unique_order (x_return_status  IN OUT NOCOPY number, --File.Sql.39 bug 4440895
                                x_rowid          IN     varchar2,
                                x_order          IN     number);
--
  procedure check_references( x_return_status      IN OUT NOCOPY number, --File.Sql.39 bug 4440895
                              x_rowid              IN varchar2,
                              x_bill_extension_id  IN number );
--
  procedure check_events ( x_return_status        IN OUT NOCOPY number, --File.Sql.39 bug 4440895
                           x_rowid                IN varchar2,
                           x_bill_extension_id    IN number );
--
  procedure get_nextval( x_return_status IN OUT NOCOPY number, --File.Sql.39 bug 4440895
                         x_nextval       IN OUT NOCOPY number ); --File.Sql.39 bug 4440895
--
end pa_billing_extensions_pkg;

 

/
