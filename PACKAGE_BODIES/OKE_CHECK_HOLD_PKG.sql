--------------------------------------------------------
--  DDL for Package Body OKE_CHECK_HOLD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_CHECK_HOLD_PKG" AS
/*$Header: OKECKHDB.pls 115.8 2003/10/13 05:21:59 yliou ship $ */

     g_api_type		CONSTANT VARCHAR2(4) := '_PKG';

/*-------------------------------------------------------------------------
 FUNCTION is_contract_hold - check if there is a hold on this contract
--------------------------------------------------------------------------*/

FUNCTION is_contract_hold(p_k_header_id IN NUMBER,
                          x_msg_data OUT NOCOPY VARCHAR2)
return BOOLEAN
is

  dummy NUMBER;

BEGIN
    select 1 into dummy
    from oke_k_holds
    where  k_header_id = p_k_header_id
       and k_line_id is null
       and deliverable_id is null
       and remove_date is null;
       x_msg_data := 'CONTRACT ' || p_k_header_id;
    return TRUE;
  Exception
    when no_data_found then
      return FALSE;
    when too_many_rows then
      x_msg_data := 'CONTRACT ' || p_k_header_id;
      return TRUE;

END is_contract_hold;


/*-------------------------------------------------------------------------
 FUNCTION is_deliverable_hold - check if there is a hold on this deliverable
--------------------------------------------------------------------------*/

FUNCTION is_deliverable_hold(p_deliverable_id IN NUMBER,
                             x_msg_data OUT NOCOPY VARCHAR2)
return BOOLEAN
is

  dummy NUMBER;

BEGIN
    select 1 into dummy
    from oke_k_holds
    where  deliverable_id = p_deliverable_id
       and remove_date is null;
    x_msg_data := 'DELIVERABLE ' || p_deliverable_id;
    return TRUE;
  Exception
    when no_data_found then
      return FALSE;
    when too_many_rows then
      x_msg_data := 'DELIVERABLE ' || p_deliverable_id;
      return TRUE;

END is_deliverable_hold;


/*-------------------------------------------------------------------------
 FUNCTION is_line_hold - check if there is a hold
                         on this line or the parent lines - recursive
--------------------------------------------------------------------------*/

FUNCTION is_line_hold(p_k_line_id IN NUMBER,
                      x_msg_data OUT NOCOPY VARCHAR2)
return BOOLEAN
is

  dummy NUMBER;
  l_parent_line_id NUMBER;

BEGIN
    select 1 into dummy
    from oke_k_holds
    where  k_line_id = p_k_line_id
       and deliverable_id is null
       and remove_date is null;
    x_msg_data := 'LINE ' || p_k_line_id;
    return TRUE;
  Exception
    when no_data_found then
        select parent_line_id into l_parent_line_id
        from oke_k_lines_v
        where k_line_id = p_k_line_id;
        if l_parent_line_id is not null
        then return is_line_hold(l_parent_line_id, x_msg_data);
        else return FALSE;
        end if;
    when too_many_rows then
      x_msg_data := 'LINE ' || p_k_line_id;
      return TRUE;

END is_line_hold;


/*-------------------------------------------------------------------------
 FUNCTION is_hold - check if it is hold on
                    contract, line, or deliverable level
 - Overloading function : with OUT parameters, return TRUE or FALSE
 - for PL/SQL in forms.
--------------------------------------------------------------------------*/

FUNCTION is_hold(p_api_version         IN  NUMBER,
    		  p_init_msg_list       IN  VARCHAR2,
       		  x_return_status       OUT NOCOPY VARCHAR2,
    		  x_msg_count           OUT NOCOPY NUMBER,
    		  x_msg_data            OUT NOCOPY VARCHAR2,
                  p_hold_level 		IN  VARCHAR2,
                  p_k_header_id		IN  NUMBER,
                  p_k_line_id		IN  NUMBER,
                  p_deliverable_id	IN  NUMBER)
                  RETURN BOOLEAN IS

    l_return_status	VARCHAR2(1)	      := OKE_API.G_RET_STS_SUCCESS;
    l_api_name		CONSTANT VARCHAR2(30) := 'IS_HOLD';
    l_api_version	CONSTANT NUMBER	      := 1.0;

BEGIN

    x_return_status := OKE_API.G_RET_STS_SUCCESS;
    x_msg_count := 0;
    x_msg_data := NULL;
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;


    if (p_hold_level = 'LINE')
    then if (is_contract_hold(p_k_header_id, x_msg_data))
         then
               return TRUE;
         else return is_line_hold(p_k_line_id, x_msg_data);
         end if;
    end if;

    if (p_hold_level = 'CONTRACT')
    then return is_contract_hold(p_k_header_id, x_msg_data);
    end if;

    if (p_hold_level = 'DELIVERABLE')
    then if (is_contract_hold(p_k_header_id, x_msg_data))
         then
               return TRUE;
         else if (is_deliverable_hold(p_deliverable_id, x_msg_data))
              then
                   return TRUE;
              else return is_line_hold(p_k_line_id, x_msg_data);
              end if;
         end if;
    end if;

END is_hold;

/*-------------------------------------------------------------------------
 FUNCTION is_hold - check if it is hold on
                    contract, line, or deliverable level
- Overloading function : no OUT parameters, return 1 or 0
- for SQL view
--------------------------------------------------------------------------*/

FUNCTION is_hold( p_hold_level 		IN  VARCHAR2,
                  p_k_header_id		IN  NUMBER,
                  p_k_line_id		IN  NUMBER,
                  p_deliverable_id	IN  NUMBER)
                  RETURN NUMBER IS
x_msg_data VARCHAR2(240) := NULL;

BEGIN

    if (p_hold_level = 'LINE')
    then if is_contract_hold(p_k_header_id, x_msg_data)
         then return 1;
         else if is_line_hold(p_k_line_id, x_msg_data)
              then return 1;
              else return 0;
              end if;
         end if;
    end if;

    if (p_hold_level = 'CONTRACT')
    then if is_contract_hold(p_k_header_id, x_msg_data)
         then return 1;
         else return 0;
         end if;
    end if;

    if (p_hold_level = 'DELIVERABLE')
    then if is_contract_hold(p_k_header_id, x_msg_data)
         then return 1;
         else if is_deliverable_hold(p_deliverable_id, x_msg_data)
              then return 1;
              else if is_line_hold(p_k_line_id, x_msg_data)
                   then return 1;
                   else return 0;
                   end if;
              end if;
         end if;
    end if;

END is_hold;


/*-------------------------------------------------------------------------
 FUNCTION get_hold_descr - get contract description
                  if the hold is on contract level
                  get line description if the hold is on line level
                  get deliverable description if the hold is on
                      deliverable level
--------------------------------------------------------------------------*/
FUNCTION get_hold_descr (p_k_header_id		IN  NUMBER,
                p_k_line_id		IN  NUMBER,
                p_deliverable_id	IN  NUMBER)
                RETURN VARCHAR2 IS
  descr         varchar2(1995) := null;

BEGIN

    IF p_k_line_id is null THEN
      /* show contract descr */
      BEGIN
        SELECT short_description
        INTO descr
        FROM okc_k_headers_tl
        WHERE id = p_k_header_id
        AND language = userenv('LANG');
      EXCEPTION
      WHEN OTHERS THEN
          descr := null;
      END;

    ELSIF p_k_line_id is not null AND p_deliverable_id is not null THEN

      /* show deliverable descr */
      BEGIN
        SELECT description
        INTO descr
        FROM oke_k_deliverables_tl
        WHERE deliverable_id = p_deliverable_id
        AND language = userenv('LANG');
      EXCEPTION
      WHEN OTHERS THEN
          descr := null;
      END;

    ELSIF p_k_line_id is not null AND p_deliverable_id is null THEN
         /* show line descr */
      BEGIN
        SELECT item_description
        INTO descr
        FROM okc_k_lines_tl
        WHERE id = p_k_line_id
        AND language = userenv('LANG');
      EXCEPTION
      WHEN OTHERS THEN
          descr := null;
      END;

    END IF;

    RETURN descr;

END get_hold_descr;


END OKE_CHECK_HOLD_PKG;

/
