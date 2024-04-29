--------------------------------------------------------
--  DDL for Package Body PO_CORE_S3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_CORE_S3" AS
/* $Header: POXCOC3B.pls 120.0 2005/06/01 16:31:13 appldev noship $*/
/*===========================================================================

  PROCEDURE NAME:	get_window_org_sob()

===========================================================================*/
PROCEDURE get_window_org_sob(x_multi_org_form_flag IN OUT NOCOPY BOOLEAN,
			     x_org_sob_id	   IN OUT NOCOPY NUMBER,
			     x_org_sob_name	   IN OUT NOCOPY VARCHAR2) is

  progress   varchar2(3)  := NULL;
  org_char   varchar2(60) := NULL;

  /* Add this variable to get multi-org information on
  ** the current product installation.
  ** (Bug 750973, zxzhang 98/11/11)
  */
  l_multi_org           VARCHAR2(1);


BEGIN
  /*
  **
  ** Get multi-org information on the current product
  ** installation.
  ** (Bug 750973, zxzhang 98/11/11)
  */
  SELECT        nvl(multi_org_flag, 'N')
  INTO          l_multi_org
  FROM          fnd_product_groups;
  IF (l_multi_org = 'N') THEN
    x_multi_org_form_flag := FALSE;
  ELSE
    x_multi_org_form_flag := TRUE;
  END IF;

  /* Note:  this will fail on a 10.5 or earlier install
  ** because the org_id column in po_system_parameters
  ** does not exist.
  */

  /* If the form uses the org picker when it opens, then
  ** check the developer profile option to get that
  ** MFG org id.  Otherwise, the form is not a true
  ** multiorg form, and we disregard this profile
  ** option.
  */

  if (x_multi_org_form_flag = TRUE) then

    x_org_sob_id := PO_MOAC_UTILS_PVT.get_current_org_id ;       -- <R12 MOAC>

    progress := '010';

    BEGIN
      /* Bug 750973: Display all the chars */
      /* SELECT substr(hou.name,1,20) */
      /* Bug 943602: Display 30 chars to be consistent with client side code */
      /*SELECT substr(hou.name,1,64)*/
      /* Bug 1040332, zxzhang, substr is dependent on character set */
      /*SELECT substr(hou.name,1,30)*/
      SELECT substrb(hou.name,1,30)
      INTO   x_org_sob_name
      FROM   hr_organization_units hou
      WHERE  hou.organization_id = x_org_sob_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
	    null;
    END;

  else

    /* If the org_id in purchasing system parameters is not
    ** null (customer is using the view-based multiorg
    ** solution introduced in R10.6) , then use this org's truncated
    ** name for the title.  Otherwise use the set of books short name.
    */

    progress := '020';
    x_org_sob_id := NULL;

    BEGIN

    SELECT org_id
    INTO   x_org_sob_id
    FROM   po_system_parameters;

    EXCEPTION
	WHEN NO_DATA_FOUND THEN

	    -- Get org_sob_id from financials_system_parameters
	    -- We need to handle this exception because the Define
	    -- Purchasing Options form calls this procedure, and prior
	    -- to setup it will not have a record.


	    null;
    END;

    if (x_org_sob_id is not null) then

      progress := '030';

      /* Since there might not be a 3-char code for fin-only
      ** operating units, we must use the org name.  The trunc
      ** to 20 chars makes this the same length as the sob short
      ** name (we cannot display a 60 character organization name
      ** in the window titles).
      */

      /* Bug 750973: Display all the chars */
      /* SELECT substr(hou.name,1,20) */
      /* Bug 943602: Display 30 chars to be consistent with client side code */
      /*SELECT substr(hou.name,1,64)*/
      /* Bug 1040332, zxzhang, substr is dependent on character set */
      /*SELECT substr(hou.name,1,30)*/
      SELECT substrb(hou.name,1,30)
      INTO   x_org_sob_name
      FROM   hr_organization_units hou
      WHERE  hou.organization_id = x_org_sob_id;

    else

      progress := '040';

      SELECT fsp.set_of_books_id,
	     gsb.short_name
      INTO   x_org_sob_id,
	     x_org_sob_name
      FROM   financials_system_parameters fsp,
	     gl_sets_of_books gsb
      WHERE  fsp.set_of_books_id = gsb.set_of_books_id;

    end if;
  end if;

EXCEPTION

  when others then
    po_message_s.sql_error('get_window_org_sob', progress, sqlcode);
    raise;

end get_window_org_sob;

END PO_CORE_S3;

/
