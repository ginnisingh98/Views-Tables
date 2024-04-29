--------------------------------------------------------
--  DDL for Package GL_BC_OPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_BC_OPTIONS_PKG" AUTHID CURRENT_USER AS
/*  $Header: glnlsbcs.pls 120.4 2005/05/05 02:07:02 kvora ship $ */

 Procedure load_row(
    x_bc_option_id      in number,
    x_bc_option_name    in varchar2,
    x_description       in varchar2,
    x_context           in varchar2,
    x_attribute1        in varchar2,
    x_attribute2        in varchar2,
    x_attribute3        in varchar2,
    x_attribute4        in varchar2,
    x_attribute5        in varchar2,
    x_attribute6        in varchar2,
    x_attribute7        in varchar2,
    x_attribute8        in varchar2,
    x_attribute9        in varchar2,
    x_attribute10       in varchar2,
    x_attribute11       in varchar2,
    x_attribute12       in varchar2,
    x_attribute13       in varchar2,
    x_attribute14       in varchar2,
    x_attribute15       in varchar2,
    x_owner             in varchar2,
    x_force_edits       in varchar2 default 'N'
   );


Procedure translate_row (
    x_bc_option_id      in number,
    x_bc_option_name    in varchar2,
    x_description       in varchar2,
    x_owner             in varchar2,
    x_force_edits       in varchar2
      );


procedure update_row(
    x_row_id            in varchar2,
    x_bc_option_id      in number,
    x_bc_option_name    in varchar2,
    x_description       in varchar2,
    x_context           in varchar2,
    x_attribute1        in varchar2,
    x_attribute2        in varchar2,
    x_attribute3        in varchar2,
    x_attribute4        in varchar2,
    x_attribute5        in varchar2,
    x_attribute6        in varchar2,
    x_attribute7        in varchar2,
    x_attribute8        in varchar2,
    x_attribute9        in varchar2,
    x_attribute10       in varchar2,
    x_attribute11       in varchar2,
    x_attribute12       in varchar2,
    x_attribute13       in varchar2,
    x_attribute14       in varchar2,
    x_attribute15       in varchar2,
    x_last_update_date  in date,
    x_last_updated_by   in number,
    x_last_update_login in number ,
    x_creation_date     in date
  );

procedure insert_row (
    x_row_id       in out NOCOPY  varchar2,
    x_bc_option_id      in number,
    x_bc_option_name    in varchar2,
    x_description       in varchar2,
    x_context           in varchar2,
    x_attribute1        in varchar2,
    x_attribute2        in varchar2,
    x_attribute3        in varchar2,
    x_attribute4        in varchar2,
    x_attribute5        in varchar2,
    x_attribute6        in varchar2,
    x_attribute7        in varchar2,
    x_attribute8        in varchar2,
    x_attribute9        in varchar2,
    x_attribute10       in varchar2,
    x_attribute11       in varchar2,
    x_attribute12       in varchar2,
    x_attribute13       in varchar2,
    x_attribute14       in varchar2,
    x_attribute15       in varchar2,
    x_last_update_date  in date,
    x_last_updated_by   in number,
    x_last_update_login in number,
    x_creation_date     in date,
    x_created_by        in number
  );

End gl_bc_options_pkg;

 

/
