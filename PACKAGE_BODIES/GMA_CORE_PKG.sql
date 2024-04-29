--------------------------------------------------------
--  DDL for Package Body GMA_CORE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMA_CORE_PKG" AS
/* $Header: GMACOREB.pls 115.8 2002/12/03 21:58:22 appldev ship $ */
FUNCTION get_date_constant(V_constant IN VARCHAR2) RETURN VARCHAR2 IS
begin
 IF (V_constant in ('SY$MIN_DATE')) THEN
    RETURN to_char(get_date_constant_d('SY$MIN_DATE'), 'DD-MON-YYYY HH24:MI:SS');
 ELSIF (V_constant in ('SY$MAX_DATE')) THEN
    RETURN to_char(get_date_constant_d('SY$MAX_DATE'), 'DD-MON-YYYY HH24:MI:SS');
 ELSIF (V_constant in ('SY$ZERODATE')) THEN
    RETURN to_char(get_date_constant_d('SY$ZERODATE'), 'DD-MON-YYYY');
-- Bug #2480810 (JKB) Changed above hard-coded values to read the profiles.
-- Bug #2607567 (JKB) Removed the time from the SY$ZERODATE value.
-- Bug #2626977 (JKB) Changed to call the new function added below.
 END IF;
end get_date_constant;

FUNCTION get_date_constant_d(V_constant IN VARCHAR2) RETURN DATE IS
begin
 IF (V_constant in ('SY$MIN_DATE')) THEN
    RETURN to_date(fnd_profile.value_wnps('SY$MIN_DATE'),'YYYY/MM/DD HH24:MI:SS');
 ELSIF (V_constant in ('SY$MAX_DATE')) THEN
    RETURN to_date(fnd_profile.value_wnps('SY$MAX_DATE'),'YYYY/MM/DD HH24:MI:SS');
 ELSIF (V_constant in ('SY$ZERODATE')) THEN
    RETURN to_date(fnd_profile.value_wnps('SY$ZERODATE'),'YYYY/MM/DD HH24:MI:SS');
 END IF;
end get_date_constant_d;

PROCEDURE check_product_installed (V_constant IN VARCHAR2,
                                   V_status   OUT NOCOPY VARCHAR2) IS
dummy   VARCHAR2(40);
ret     BOOLEAN;
BEGIN
  ret := fnd_installation.get_app_info(V_constant, V_status, dummy, dummy);
END check_product_installed;

end GMA_CORE_PKG;

/
