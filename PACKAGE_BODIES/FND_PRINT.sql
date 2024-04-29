--------------------------------------------------------
--  DDL for Package Body FND_PRINT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_PRINT" as
/* $Header: AFPRGPIB.pls 120.3 2006/03/06 13:21:39 pferguso ship $ */



/*
**  STYLE_INFORMATION  -
*/
function STYLE_INFORMATION(style    in varchar2,
                           p_width  out nocopy number,
                           p_length out nocopy number) return boolean is

begin

    if (style is null)
    then
        return false;
    end if;

    select width, length
      into p_width, p_length
      from fnd_printer_styles
      where printer_style_name = style;

    return true;

exception
   when others then
     return false;

end STYLE_INFORMATION;



/*
**  PRINTER_INFORMATION -
*/
function PRINTER_INFORMATION(printer in varchar2,
                             style   in varchar2) return boolean is

   dummy    fnd_printer.printer_name%TYPE;
begin

   select fp.printer_name
     into dummy
     from fnd_printer fp, fnd_printer_information fpi
     where fp.printer_name = printer
     and fp.printer_type = fpi.printer_type
     and fpi.printer_style = style;

   return true;

exception
   when others then
     return false;

end PRINTER_INFORMATION;




procedure SET_INVALID_STYLE( STYLE     in varchar2, PRINTER in varchar2,
                             MINWIDTH  in number,   MAXWIDTH  in number,
                             MINLENGTH in number,   MAXLENGTH in number) is

begin
        FND_MESSAGE.SET_NAME('FND', 'PRT-Invalid style');
        FND_MESSAGE.SET_TOKEN('STYLE', style, FALSE);

        if (minwidth <> 0)
        then
            FND_MESSAGE.SET_TOKEN('MINWIDTH', minwidth, FALSE);
        else
            FND_MESSAGE.SET_TOKEN('MINWIDTH', 'FND-None', TRUE);
        end if;

        if (maxwidth <> 0)
        then
            FND_MESSAGE.SET_TOKEN('MAXWIDTH', maxwidth, FALSE);
        else
            FND_MESSAGE.SET_TOKEN('MAXWIDTH', 'FND-None', TRUE);
        end if;

        if (minlength <> 0)
        then
            FND_MESSAGE.SET_TOKEN('MINLENGTH', minlength, FALSE);
        else
            FND_MESSAGE.SET_TOKEN('MINLENGTH', 'FND-None', TRUE);
        end if;

        if (maxlength <> 0)
        then
            FND_MESSAGE.SET_TOKEN('MAXLENGTH', maxlength, FALSE);
        else
            FND_MESSAGE.SET_TOKEN('MAXLENGTH', 'FND-None', TRUE);
        end if;

        FND_MESSAGE.SET_TOKEN('PRINTER', printer, FALSE);

end SET_INVALID_STYLE;


/*
 **   GET_STYLE -
*/
function GET_STYLE(STYLE      in  varchar2,
                   MINWIDTH   in number,  MAXWIDTH  in number,
                   MINLENGTH  in number,  MAXLENGTH in number,
                   REQUIRED   in boolean, PRINTER in varchar2,
                   VALIDSTYLE out nocopy varchar2) return boolean is

cursor C1(MINW number, MAXW number, MINL number, MAXL number) is
    select  printer_style_name
            from fnd_printer_styles
        where width >= minw
        and (maxw is null or width <= maxw)
        and length >= minl
        and (maxl is null or length <= maxl)
        order by sequence;

width  number(4) := 0;
length number(4) := 0 ;
valid  boolean := FALSE;
print_style varchar2(30);

begin

    validstyle := NULL;

    valid := STYLE_INFORMATION(style, width, length);

    if ((valid = FALSE) and ( (width = 0) or (length = 0) ) )
    then  -- could not find a valid style.
        return FALSE;
    end if;

    if ( (minwidth is not null and minwidth > width)    or
         (maxwidth is not null and maxwidth < width)    or
         (minlength is not null and minlength > length) or
             (maxlength is not null and maxlength < length)
       )
    then
        -- set valid to FALSE
        -- couldnt find a valid printer
        valid := FALSE;
    end if;

    if (valid = TRUE)
    then    -- copy if found
        validstyle := style;
        return TRUE;
    end if;

    if (required = TRUE)
    then

        set_invalid_style(style, printer, minwidth, maxwidth, minlength, maxlength);
        return FALSE;

    end if;

     ----------------------------------------------------------------------
     --   Style is invalid but not required.                             --
     --   Find a valid style w/ the lowest preference sequence.          --
     ----------------------------------------------------------------------

     if (printer is not null and  PRINTER_INFORMATION(printer, style) = FALSE) then
       set_invalid_style(style, printer, minwidth, maxwidth, minlength, maxlength);
       return FALSE;
     end if;

     open C1(minwidth, maxwidth, minlength, maxlength);
     fetch C1 into print_style;
     if C1%NOTFOUND then
        close C1;
        set_invalid_style(style, printer, minwidth, maxwidth, minlength, maxlength);
        return FALSE;
     end if;

     close C1;
     validstyle := print_style;
     return TRUE;

exception
    when OTHERS then
        if C1%ISOPEN then
          close C1;
        end if;
        return FALSE;

end GET_STYLE;



end FND_PRINT;

/
