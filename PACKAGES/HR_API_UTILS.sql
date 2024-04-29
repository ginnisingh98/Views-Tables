--------------------------------------------------------
--  DDL for Package HR_API_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_API_UTILS" AUTHID CURRENT_USER AS
/* $Header: hrapiutl.pkh 115.1 2002/11/29 12:22:34 apholt ship $ */
-- A procedure to parse the dynamic sql.
--
  procedure call_parse(p_cursor IN OUT NOCOPY NUMBER
                      ,p_proc IN OUT NOCOPY varchar2
                      );
  --
  -- A procedure to bind a variable of type varchar2.
  --
  PROCEDURE bind_var(p_cursor   IN     NUMBER
                    ,p_bind_var IN     VARCHAR2
                    ,p_out_val  IN OUT NOCOPY VARCHAR2
                    );
  --
  -- A procedure to bind a variable of type number.
  --
  PROCEDURE bind_num(p_cursor   IN     NUMBER
                    ,p_bind_var IN     VARCHAR2
                    ,p_out_val  IN OUT NOCOPY NUMBER
                    );
  --
  -- A procedure to bind a variable of type date.
  --
  PROCEDURE bind_date(p_cursor   IN     NUMBER
                     ,p_bind_var IN     VARCHAR2
                     ,p_out_val  IN OUT NOCOPY DATE
                     );
  --
  -- A procedure to return a value from a bound variable of type varchar2.
  --
  PROCEDURE get_var(p_cursor   IN     NUMBER
                   ,p_bind_var IN     VARCHAR2
                   ,p_out_val  IN OUT NOCOPY VARCHAR2
                   );
  --
  -- A procedure to return a value from a bound variable of type number.
  --
  PROCEDURE get_num(p_cursor   IN     NUMBER
                   ,p_bind_var IN     VARCHAR2
                   ,p_out_val  IN OUT NOCOPY NUMBER
                   );
  --
  -- A procedure to return a value from a bound variable of type date.
  --
  PROCEDURE get_date(p_cursor   IN     NUMBER
                    ,p_bind_var IN     VARCHAR2
                    ,p_out_val  IN OUT NOCOPY DATE
                    );
  --
  --
end hr_api_utils;

 

/
