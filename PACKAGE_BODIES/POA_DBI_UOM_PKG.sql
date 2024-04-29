--------------------------------------------------------
--  DDL for Package Body POA_DBI_UOM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_DBI_UOM_PKG" as
/* $Header: poadbiuomb.pls 120.2 2008/01/17 10:53:18 nchava ship $ */


function convert_to_item_base_uom(p_item_id number
                                 ,p_org_id number
                                 ,p_from_unit_of_measure varchar2
                                 ,p_item_primary_uom_code VARCHAR2)
return number is

begin

  if(p_item_primary_uom_code is null) then

    if (p_from_unit_of_measure = get_item_base_uom(p_item_id, p_org_id, p_from_unit_of_measure)) then
      return 1;
    end if;

  end if;

  RETURN convert_to_item_base_uom(
             p_item_id               => p_item_id
           , p_org_id                => p_org_id
           , p_from_unit_of_measure  => p_from_unit_of_measure
           , p_from_uom_code         => NULL
           , p_item_primary_uom_code => p_item_primary_uom_code) ;
end convert_to_item_base_uom;



/* Overloaded function: convert_to_item_base_uom
   Additional parameters: p_from_uom_code
*/
function convert_to_item_base_uom
(  p_item_id               NUMBER
 , p_org_id                NUMBER
 , p_from_unit_of_measure  VARCHAR2
 , p_from_uom_code         VARCHAR2
 , p_item_primary_uom_code VARCHAR2
) RETURN NUMBER IS

  l_line_uom_class varchar2(10);
  l_line_base_uom varchar2(1);
  l_item_uom_class varchar2(10) := p_item_primary_uom_code;
  l_item_base_uom varchar2(1);
  l_item_primary_uom_code varchar2(3);

  -- standard and intra class conversion using unit_of_measure
  cursor l_standard_conversion(l_item_id number
                              ,l_uom_class varchar2
                              ,l_unit_of_measure varchar2) is
     select conversion_rate
       from mtl_uom_conversions
      where uom_class = l_uom_class
        and unit_of_measure = l_unit_of_measure
        and INVENTORY_ITEM_ID in (l_item_id,0)
     --  to take care of item specific vs standard conversion
     order by INVENTORY_ITEM_ID desc;

  l_standard_conversion_rec l_standard_conversion%rowtype;


  -- standard and intra class conversion using uom_code
  cursor l_standard_conversion2(l_item_id   NUMBER
                              ,l_uom_class VARCHAR2
                              ,l_uom_code  VARCHAR2) is
     SELECT conversion_rate
       FROM mtl_uom_conversions
      WHERE uom_class = l_uom_class
        AND uom_code  = l_uom_code
        AND INVENTORY_ITEM_ID in (l_item_id,0)
     --  to take care of item specific vs standard conversion
     ORDER BY INVENTORY_ITEM_ID desc ;

  l_standard_conversion2_rec l_standard_conversion2%rowtype;

  cursor l_class_conversion(l_item_id number
                           ,l_from_uom_class varchar2
                           ,l_to_uom_class varchar2) is
     select conversion_rate,from_uom_class
            -- to take care of two way conversions
       from MTL_UOM_CLASS_CONVERSIONS
      where inventory_item_id = l_item_id
        and FROM_UOM_CLASS in (l_from_uom_class,l_to_uom_class)
	and TO_UOM_CLASS in (l_from_uom_class,l_to_uom_class)
     order by decode(FROM_UOM_CLASS,l_from_uom_class,1,2);

  l_class_conversion_rec l_class_conversion%rowtype;

  l_from_uom_class varchar2(10);

  l_conversion NUMBER;
  l_item_conversion NUMBER;
  l_class_conv NUMBER;
begin
-- Given a PO Line, get the uom class and if it is the  base uom

  if (p_item_id is null) then return 1; end if;

  begin
    IF (p_from_uom_code IS NULL) THEN
      -- Get uom_class and base_uom_flag using unit_of_measure
      select uom.UOM_CLASS,uom.BASE_UOM_FLAG
        into l_line_uom_class,l_line_base_uom
        from mtl_units_of_measure uom
       where uom.UNIT_OF_MEASURE = p_from_unit_of_measure;
     ELSE
        -- Get uom_class and base_uom_flag using uom_code
        SELECT  uom.uom_class
              , uom.base_uom_flag
        INTO l_line_uom_class
           , l_line_base_uom
        FROM mtl_units_of_measure uom
        WHERE uom.uom_code = p_from_uom_code ;
      END IF ;
  exception
    when no_data_found then
      return -1;
  end;

-- Given a non-one-time item PO Line, get the uom class and if it is
-- the base uom for the primary uom of the given item and the
-- corresponding fsp.inventory org
  begin
      if(p_item_primary_uom_code is null) then
        select uom.UOM_CLASS, uom.base_uom_flag, item.primary_uom_code
          into l_item_uom_class, l_item_base_uom, l_item_primary_uom_code
          from mtl_units_of_measure uom
              ,mtl_system_items item
         where uom.UOM_CODE = item.PRIMARY_UOM_CODE
           and item.inventory_item_id = p_item_id
           and item.organization_id = p_org_id;
      else
        select uom_class, base_uom_flag
          into l_item_uom_class, l_item_base_uom
          from mtl_units_of_measure
         where uom_code = p_item_primary_uom_code;
      end if;
  exception
     when no_data_found then
       return -2;
  end;

  -- to convert to the primary uom of the item if the primary UOM is not the base UOM of that UOM class
  if(l_item_base_uom = 'Y') then
     l_item_conversion := 1.0;
  else
     open l_standard_conversion2(0, l_item_uom_class, nvl(p_item_primary_uom_code, l_item_primary_uom_code));
     fetch l_standard_conversion2 INTO l_standard_conversion2_rec ;
     IF l_standard_conversion2%NOTFOUND then
          CLOSE l_standard_conversion2 ;
          RETURN -6 ;
     ELSE
          CLOSE l_standard_conversion2 ;
          l_item_conversion := 1.0/l_standard_conversion2_rec.conversion_rate ;
     end if ;
   end if;

 -- same class
  if(l_line_uom_class = l_item_uom_class) then
    if(l_line_base_uom = 'Y') then
      return 1.0 * l_item_conversion; -- no further conversion required
    else
      IF p_from_uom_code IS NULL THEN
        open l_standard_conversion(p_item_id,l_line_uom_class,p_from_unit_of_measure);
        fetch l_standard_conversion into l_standard_conversion_rec;
        if l_standard_conversion%NOTFOUND then
          close l_standard_conversion;
          return -3;
        else
          close l_standard_conversion;
          return l_standard_conversion_rec.conversion_rate * l_item_conversion;
        end if;
      ELSE
        -- get conversion based on uom_code
        OPEN l_standard_conversion2(p_item_id,l_line_uom_class,p_from_uom_code) ;
        FETCH l_standard_conversion2 INTO l_standard_conversion2_rec ;
        IF l_standard_conversion2%NOTFOUND then
          CLOSE l_standard_conversion2 ;
          RETURN -3 ;
        ELSE
          CLOSE l_standard_conversion2 ;
          RETURN l_standard_conversion2_rec.conversion_rate * l_item_conversion;
        end if ;
      end if ;
    end if;
  else -- inter class
    -- lets first get conversion factor for the line uom to line uom class's base uom
    if(l_line_base_uom = 'Y') then
      l_conversion := 1.0;
    else
      IF p_from_uom_code IS NULL THEN
        open l_standard_conversion(p_item_id,l_line_uom_class,p_from_unit_of_measure);
        fetch l_standard_conversion into l_standard_conversion_rec;
        if l_standard_conversion%NOTFOUND then
          close l_standard_conversion;
          return -4;
        else
          close l_standard_conversion;
          l_conversion := l_standard_conversion_rec.conversion_rate;
        end if;
      ELSE
        -- get conversion based on uom_code
        OPEN l_standard_conversion2(p_item_id,l_line_uom_class,p_from_uom_code);
        FETCH l_standard_conversion2 into l_standard_conversion2_rec;
        IF l_standard_conversion2%NOTFOUND then
          CLOSE l_standard_conversion2;
          RETURN -4;
        ELSE
          CLOSE l_standard_conversion2;
          l_conversion := l_standard_conversion2_rec.conversion_rate;
        END IF;
      END IF ;
    end if;
    -- There could be a single conersion or two conversions back and forth
    -- with different values. We want to start from line uom class if possible
    open l_class_conversion(p_item_id,l_line_uom_class,l_item_uom_class);
    fetch l_class_conversion into l_class_conversion_rec;
    if(l_class_conversion%NOTFOUND) then
      close l_class_conversion;
      return -5;
    else
      close l_class_conversion;
      l_class_conv := l_class_conversion_rec.conversion_rate;
      l_from_uom_class := l_class_conversion_rec.from_uom_class;
    end if;

    if(l_from_uom_class = l_line_uom_class) then
      l_class_conv := 1.0/l_class_conv;
    end if;

    return l_conversion * l_class_conv * l_item_conversion;
  end if;
end convert_to_item_base_uom;

/*
  This function is called by the POD Fact Refreshing program for populating
  the conversion rates between a Negotiation Transaction UOM to that of PO
  transaction UOM, only when the Item is being looked into is a One Time Item.
*/
FUNCTION convert_neg_to_po_uom( p_from_unit_of_measure  VARCHAR2,
                                p_to_unit_of_measure VARCHAR2
			      )
               RETURN NUMBER
IS
  l_conversion_rate number;
BEGIN
 l_conversion_rate := 1;

SELECT (from_uom.conversion_rate * (1/to_uom.conversion_rate)) rate into l_conversion_rate
FROM
   (SELECT conversion_rate, uom_class FROM mtl_uom_conversions WHERE unit_of_measure=p_from_unit_of_measure AND inventory_item_id=0) from_uom,
   (SELECT conversion_rate, uom_class FROM mtl_uom_conversions WHERE unit_of_measure=p_to_unit_of_measure AND inventory_item_id=0) to_uom
WHERE
     from_uom.uom_class=to_uom.uom_class;

 return l_conversion_rate;
END convert_neg_to_po_uom;


function get_item_base_uom(p_item_id number
                           ,p_org_id number
                           ,p_from_unit_of_measure varchar2)
               return varchar2
is

l_base_uom varchar2(25);

begin

  if(p_item_id is not null) then
    select primary_unit_of_measure
    into l_base_uom
    from mtl_system_items
    where inventory_item_id = p_item_id
    and organization_id = p_org_id;
  else
    l_base_uom := p_from_unit_of_measure;
  end if;

  return l_base_uom;

exception
  when others then
   return '-1';

end;

end poa_dbi_uom_pkg;

/
