--------------------------------------------------------
--  DDL for Package Body HR_CANVAS_PROPERTIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CANVAS_PROPERTIES_PKG" as
/* $Header: hrcnplct.pkb 115.4 2002/12/09 16:29:30 hjonnala noship $ */
-- -----------------------------------------------------------------------------
-- |-----------------------------< update_copies >-----------------------------|
-- -----------------------------------------------------------------------------
procedure UPDATE_COPIES (
  X_CANVAS_PROPERTY_ID in NUMBER,
  X_FORM_CANVAS_ID in NUMBER,
  X_TEMPLATE_CANVAS_ID in NUMBER,
  X_HEIGHT in NUMBER,
  X_VISIBLE in NUMBER,
  X_WIDTH in NUMBER,
  X_X_POSITION in NUMBER,
  X_Y_POSITION in NUMBER,
  X_INFORMATION_CATEGORY in VARCHAR2,
  X_INFORMATION1 in VARCHAR2,
  X_INFORMATION2 in VARCHAR2,
  X_INFORMATION3 in VARCHAR2,
  X_INFORMATION4 in VARCHAR2,
  X_INFORMATION5 in VARCHAR2,
  X_INFORMATION6 in VARCHAR2,
  X_INFORMATION7 in VARCHAR2,
  X_INFORMATION8 in VARCHAR2,
  X_INFORMATION9 in VARCHAR2,
  X_INFORMATION10 in VARCHAR2,
  X_INFORMATION11 in VARCHAR2,
  X_INFORMATION12 in VARCHAR2,
  X_INFORMATION13 in VARCHAR2,
  X_INFORMATION14 in VARCHAR2,
  X_INFORMATION15 in VARCHAR2,
  X_INFORMATION16 in VARCHAR2,
  X_INFORMATION17 in VARCHAR2,
  X_INFORMATION18 in VARCHAR2,
  X_INFORMATION19 in VARCHAR2,
  X_INFORMATION20 in VARCHAR2,
  X_INFORMATION21 in VARCHAR2,
  X_INFORMATION22 in VARCHAR2,
  X_INFORMATION23 in VARCHAR2,
  X_INFORMATION24 in VARCHAR2,
  X_INFORMATION25 in VARCHAR2,
  X_INFORMATION26 in VARCHAR2,
  X_INFORMATION27 in VARCHAR2,
  X_INFORMATION28 in VARCHAR2,
  X_INFORMATION29 in VARCHAR2,
  X_INFORMATION30 in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor csr_original is
    select *
      from HR_CANVAS_PROPERTIES
     where CANVAS_PROPERTY_ID = X_CANVAS_PROPERTY_ID;
  l_original csr_original%rowtype;
  cursor csr_copies is
    select cnp.canvas_property_id
      from HR_CANVAS_PROPERTIES cnp
          ,HR_TEMPLATE_CANVASES_B tcn
          ,HR_TEMPLATE_WINDOWS_B twn
          ,HR_TEMPLATE_CANVASES_B tco
     where cnp.TEMPLATE_CANVAS_ID = tcn.TEMPLATE_CANVAS_ID
       and tcn.TEMPLATE_WINDOW_ID = twn.TEMPLATE_WINDOW_ID
       and twn.FORM_TEMPLATE_ID in (select sft.FORM_TEMPLATE_ID_TO
                                      from HR_SOURCE_FORM_TEMPLATES sft
                                start with sft.FORM_TEMPLATE_ID_FROM = (select tw1.FORM_TEMPLATE_ID
                                                                          from HR_TEMPLATE_WINDOWS tw1
                                                                         where tw1.TEMPLATE_WINDOW_ID = tco.TEMPLATE_WINDOW_ID)
                                connect by sft.FORM_TEMPLATE_ID_FROM = prior sft.FORM_TEMPLATE_ID_TO)
       and tcn.FORM_CANVAS_ID = tco.FORM_CANVAS_ID
       and tco.TEMPLATE_CANVAS_ID = X_TEMPLATE_CANVAS_ID;
begin
  if (X_TEMPLATE_CANVAS_ID is not null) then
    open csr_original;
    fetch csr_original into l_original;
    if csr_original%found then
      close csr_original;
      for l_copy in csr_copies loop
        update HR_CANVAS_PROPERTIES set
          HEIGHT = decode(nvl(HEIGHT,hr_api.g_number),nvl(l_original.HEIGHT,hr_api.g_number),X_HEIGHT,HEIGHT),
          VISIBLE = decode(nvl(VISIBLE,hr_api.g_number),nvl(l_original.VISIBLE,hr_api.g_number),X_VISIBLE,VISIBLE),
          WIDTH = decode(nvl(WIDTH,hr_api.g_number),nvl(l_original.WIDTH,hr_api.g_number),X_WIDTH,WIDTH),
          X_POSITION = decode(nvl(X_POSITION,hr_api.g_number),nvl(l_original.X_POSITION,hr_api.g_number),X_X_POSITION,X_POSITION),
          Y_POSITION = decode(nvl(Y_POSITION,hr_api.g_number),nvl(l_original.Y_POSITION,hr_api.g_number),X_Y_POSITION,Y_POSITION),
          INFORMATION_CATEGORY = decode(nvl(INFORMATION_CATEGORY,hr_api.g_varchar2),nvl(l_original.INFORMATION_CATEGORY,hr_api.g_varchar2),X_INFORMATION_CATEGORY,INFORMATION_CATEGORY),
          INFORMATION1  = decode(nvl(INFORMATION1 ,hr_api.g_varchar2),nvl(l_original.INFORMATION1 ,hr_api.g_varchar2),X_INFORMATION1 ,INFORMATION1 ),
          INFORMATION2  = decode(nvl(INFORMATION2 ,hr_api.g_varchar2),nvl(l_original.INFORMATION2 ,hr_api.g_varchar2),X_INFORMATION2 ,INFORMATION2 ),
          INFORMATION3  = decode(nvl(INFORMATION3 ,hr_api.g_varchar2),nvl(l_original.INFORMATION3 ,hr_api.g_varchar2),X_INFORMATION3 ,INFORMATION3 ),
          INFORMATION4  = decode(nvl(INFORMATION4 ,hr_api.g_varchar2),nvl(l_original.INFORMATION4 ,hr_api.g_varchar2),X_INFORMATION4 ,INFORMATION4 ),
          INFORMATION5  = decode(nvl(INFORMATION5 ,hr_api.g_varchar2),nvl(l_original.INFORMATION5 ,hr_api.g_varchar2),X_INFORMATION5 ,INFORMATION5 ),
          INFORMATION6  = decode(nvl(INFORMATION6 ,hr_api.g_varchar2),nvl(l_original.INFORMATION6 ,hr_api.g_varchar2),X_INFORMATION6 ,INFORMATION6 ),
          INFORMATION7  = decode(nvl(INFORMATION7 ,hr_api.g_varchar2),nvl(l_original.INFORMATION7 ,hr_api.g_varchar2),X_INFORMATION7 ,INFORMATION7 ),
          INFORMATION8  = decode(nvl(INFORMATION8 ,hr_api.g_varchar2),nvl(l_original.INFORMATION8 ,hr_api.g_varchar2),X_INFORMATION8 ,INFORMATION8 ),
          INFORMATION9  = decode(nvl(INFORMATION9 ,hr_api.g_varchar2),nvl(l_original.INFORMATION9 ,hr_api.g_varchar2),X_INFORMATION9 ,INFORMATION9 ),
          INFORMATION10 = decode(nvl(INFORMATION10,hr_api.g_varchar2),nvl(l_original.INFORMATION10,hr_api.g_varchar2),X_INFORMATION10,INFORMATION10),
          INFORMATION11 = decode(nvl(INFORMATION11,hr_api.g_varchar2),nvl(l_original.INFORMATION11,hr_api.g_varchar2),X_INFORMATION11,INFORMATION11),
          INFORMATION12 = decode(nvl(INFORMATION12,hr_api.g_varchar2),nvl(l_original.INFORMATION12,hr_api.g_varchar2),X_INFORMATION12,INFORMATION12),
          INFORMATION13 = decode(nvl(INFORMATION13,hr_api.g_varchar2),nvl(l_original.INFORMATION13,hr_api.g_varchar2),X_INFORMATION13,INFORMATION13),
          INFORMATION14 = decode(nvl(INFORMATION14,hr_api.g_varchar2),nvl(l_original.INFORMATION14,hr_api.g_varchar2),X_INFORMATION14,INFORMATION14),
          INFORMATION15 = decode(nvl(INFORMATION15,hr_api.g_varchar2),nvl(l_original.INFORMATION15,hr_api.g_varchar2),X_INFORMATION15,INFORMATION15),
          INFORMATION16 = decode(nvl(INFORMATION16,hr_api.g_varchar2),nvl(l_original.INFORMATION16,hr_api.g_varchar2),X_INFORMATION16,INFORMATION16),
          INFORMATION17 = decode(nvl(INFORMATION17,hr_api.g_varchar2),nvl(l_original.INFORMATION17,hr_api.g_varchar2),X_INFORMATION17,INFORMATION17),
          INFORMATION18 = decode(nvl(INFORMATION18,hr_api.g_varchar2),nvl(l_original.INFORMATION18,hr_api.g_varchar2),X_INFORMATION18,INFORMATION18),
          INFORMATION19 = decode(nvl(INFORMATION19,hr_api.g_varchar2),nvl(l_original.INFORMATION19,hr_api.g_varchar2),X_INFORMATION19,INFORMATION19),
          INFORMATION20 = decode(nvl(INFORMATION20,hr_api.g_varchar2),nvl(l_original.INFORMATION20,hr_api.g_varchar2),X_INFORMATION20,INFORMATION20),
          INFORMATION21 = decode(nvl(INFORMATION21,hr_api.g_varchar2),nvl(l_original.INFORMATION21,hr_api.g_varchar2),X_INFORMATION21,INFORMATION21),
          INFORMATION22 = decode(nvl(INFORMATION22,hr_api.g_varchar2),nvl(l_original.INFORMATION22,hr_api.g_varchar2),X_INFORMATION22,INFORMATION22),
          INFORMATION23 = decode(nvl(INFORMATION23,hr_api.g_varchar2),nvl(l_original.INFORMATION23,hr_api.g_varchar2),X_INFORMATION23,INFORMATION23),
          INFORMATION24 = decode(nvl(INFORMATION24,hr_api.g_varchar2),nvl(l_original.INFORMATION24,hr_api.g_varchar2),X_INFORMATION24,INFORMATION24),
          INFORMATION25 = decode(nvl(INFORMATION25,hr_api.g_varchar2),nvl(l_original.INFORMATION25,hr_api.g_varchar2),X_INFORMATION25,INFORMATION25),
          INFORMATION26 = decode(nvl(INFORMATION26,hr_api.g_varchar2),nvl(l_original.INFORMATION26,hr_api.g_varchar2),X_INFORMATION26,INFORMATION26),
          INFORMATION27 = decode(nvl(INFORMATION27,hr_api.g_varchar2),nvl(l_original.INFORMATION27,hr_api.g_varchar2),X_INFORMATION27,INFORMATION27),
          INFORMATION28 = decode(nvl(INFORMATION28,hr_api.g_varchar2),nvl(l_original.INFORMATION28,hr_api.g_varchar2),X_INFORMATION28,INFORMATION28),
          INFORMATION29 = decode(nvl(INFORMATION29,hr_api.g_varchar2),nvl(l_original.INFORMATION29,hr_api.g_varchar2),X_INFORMATION29,INFORMATION29),
          INFORMATION30 = decode(nvl(INFORMATION30,hr_api.g_varchar2),nvl(l_original.INFORMATION30,hr_api.g_varchar2),X_INFORMATION30,INFORMATION30),
          LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
          LAST_UPDATED_BY = X_LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
        where CANVAS_PROPERTY_ID = l_copy.CANVAS_PROPERTY_ID;
        if (sql%notfound) then
          raise no_data_found;
        end if;
      end loop;
    else
      close csr_original;
    end if;
  end if;
end UPDATE_COPIES;
--
-- -----------------------------------------------------------------------------
-- |-----------------------------< owner_to_who >------------------------------|
-- -----------------------------------------------------------------------------
procedure OWNER_TO_WHO (
  X_OWNER in VARCHAR2,
  X_CREATION_DATE out nocopy DATE,
  X_CREATED_BY out nocopy NUMBER,
  X_LAST_UPDATE_DATE out nocopy DATE,
  X_LAST_UPDATED_BY out nocopy NUMBER,
  X_LAST_UPDATE_LOGIN out nocopy NUMBER
) is
begin
  if X_OWNER = 'SEED' then
    X_CREATED_BY := 1;
    X_LAST_UPDATED_BY := 1;
  else
    X_CREATED_BY := 0;
    X_LAST_UPDATED_BY := 0;
  end if;
  X_CREATION_DATE := sysdate;
  X_LAST_UPDATE_DATE := sysdate;
  X_LAST_UPDATE_LOGIN := 0;
exception
when others then
X_CREATION_DATE := null;
X_CREATED_BY := null;
X_LAST_UPDATE_DATE := null;
X_LAST_UPDATED_BY := null;
X_LAST_UPDATE_LOGIN := null;
raise;

end OWNER_TO_WHO;
--
-- -----------------------------------------------------------------------------
-- |------------------------------< insert_row >-------------------------------|
-- -----------------------------------------------------------------------------
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_CANVAS_PROPERTY_ID in NUMBER,
  X_INFORMATION13 in VARCHAR2,
  X_INFORMATION14 in VARCHAR2,
  X_INFORMATION15 in VARCHAR2,
  X_INFORMATION16 in VARCHAR2,
  X_INFORMATION17 in VARCHAR2,
  X_INFORMATION18 in VARCHAR2,
  X_INFORMATION19 in VARCHAR2,
  X_INFORMATION20 in VARCHAR2,
  X_INFORMATION21 in VARCHAR2,
  X_INFORMATION22 in VARCHAR2,
  X_INFORMATION23 in VARCHAR2,
  X_INFORMATION24 in VARCHAR2,
  X_INFORMATION25 in VARCHAR2,
  X_INFORMATION26 in VARCHAR2,
  X_INFORMATION27 in VARCHAR2,
  X_INFORMATION28 in VARCHAR2,
  X_INFORMATION29 in VARCHAR2,
  X_INFORMATION30 in VARCHAR2,
  X_FORM_CANVAS_ID in NUMBER,
  X_TEMPLATE_CANVAS_ID in NUMBER,
  X_HEIGHT in NUMBER,
  X_VISIBLE in NUMBER,
  X_WIDTH in NUMBER,
  X_X_POSITION in NUMBER,
  X_Y_POSITION in NUMBER,
  X_INFORMATION_CATEGORY in VARCHAR2,
  X_INFORMATION1 in VARCHAR2,
  X_INFORMATION2 in VARCHAR2,
  X_INFORMATION3 in VARCHAR2,
  X_INFORMATION4 in VARCHAR2,
  X_INFORMATION5 in VARCHAR2,
  X_INFORMATION6 in VARCHAR2,
  X_INFORMATION7 in VARCHAR2,
  X_INFORMATION8 in VARCHAR2,
  X_INFORMATION9 in VARCHAR2,
  X_INFORMATION10 in VARCHAR2,
  X_INFORMATION11 in VARCHAR2,
  X_INFORMATION12 in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from HR_CANVAS_PROPERTIES
    where CANVAS_PROPERTY_ID = X_CANVAS_PROPERTY_ID
    ;

begin
  insert into HR_CANVAS_PROPERTIES (
    INFORMATION13,
    INFORMATION14,
    INFORMATION15,
    INFORMATION16,
    INFORMATION17,
    INFORMATION18,
    INFORMATION19,
    INFORMATION20,
    INFORMATION21,
    INFORMATION22,
    INFORMATION23,
    INFORMATION24,
    INFORMATION25,
    INFORMATION26,
    INFORMATION27,
    INFORMATION28,
    INFORMATION29,
    INFORMATION30,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    CANVAS_PROPERTY_ID,
    FORM_CANVAS_ID,
    TEMPLATE_CANVAS_ID,
    HEIGHT,
    VISIBLE,
    WIDTH,
    X_POSITION,
    Y_POSITION,
    INFORMATION_CATEGORY,
    INFORMATION1,
    INFORMATION2,
    INFORMATION3,
    INFORMATION4,
    INFORMATION5,
    INFORMATION6,
    INFORMATION7,
    INFORMATION8,
    INFORMATION9,
    INFORMATION10,
    INFORMATION11,
    INFORMATION12
  ) VALUES(
    X_INFORMATION13,
    X_INFORMATION14,
    X_INFORMATION15,
    X_INFORMATION16,
    X_INFORMATION17,
    X_INFORMATION18,
    X_INFORMATION19,
    X_INFORMATION20,
    X_INFORMATION21,
    X_INFORMATION22,
    X_INFORMATION23,
    X_INFORMATION24,
    X_INFORMATION25,
    X_INFORMATION26,
    X_INFORMATION27,
    X_INFORMATION28,
    X_INFORMATION29,
    X_INFORMATION30,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_CANVAS_PROPERTY_ID,
    X_FORM_CANVAS_ID,
    X_TEMPLATE_CANVAS_ID,
    X_HEIGHT,
    X_VISIBLE,
    X_WIDTH,
    X_X_POSITION,
    X_Y_POSITION,
    X_INFORMATION_CATEGORY,
    X_INFORMATION1,
    X_INFORMATION2,
    X_INFORMATION3,
    X_INFORMATION4,
    X_INFORMATION5,
    X_INFORMATION6,
    X_INFORMATION7,
    X_INFORMATION8,
    X_INFORMATION9,
    X_INFORMATION10,
    X_INFORMATION11,
    X_INFORMATION12);
  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
end INSERT_ROW;
--
-- -----------------------------------------------------------------------------
-- |-------------------------------< lock_row >--------------------------------|
-- -----------------------------------------------------------------------------
procedure LOCK_ROW (
  X_CANVAS_PROPERTY_ID in NUMBER,
  X_INFORMATION13 in VARCHAR2,
  X_INFORMATION14 in VARCHAR2,
  X_INFORMATION15 in VARCHAR2,
  X_INFORMATION16 in VARCHAR2,
  X_INFORMATION17 in VARCHAR2,
  X_INFORMATION18 in VARCHAR2,
  X_INFORMATION19 in VARCHAR2,
  X_INFORMATION20 in VARCHAR2,
  X_INFORMATION21 in VARCHAR2,
  X_INFORMATION22 in VARCHAR2,
  X_INFORMATION23 in VARCHAR2,
  X_INFORMATION24 in VARCHAR2,
  X_INFORMATION25 in VARCHAR2,
  X_INFORMATION26 in VARCHAR2,
  X_INFORMATION27 in VARCHAR2,
  X_INFORMATION28 in VARCHAR2,
  X_INFORMATION29 in VARCHAR2,
  X_INFORMATION30 in VARCHAR2,
  X_FORM_CANVAS_ID in NUMBER,
  X_TEMPLATE_CANVAS_ID in NUMBER,
  X_HEIGHT in NUMBER,
  X_VISIBLE in NUMBER,
  X_WIDTH in NUMBER,
  X_X_POSITION in NUMBER,
  X_Y_POSITION in NUMBER,
  X_INFORMATION_CATEGORY in VARCHAR2,
  X_INFORMATION1 in VARCHAR2,
  X_INFORMATION2 in VARCHAR2,
  X_INFORMATION3 in VARCHAR2,
  X_INFORMATION4 in VARCHAR2,
  X_INFORMATION5 in VARCHAR2,
  X_INFORMATION6 in VARCHAR2,
  X_INFORMATION7 in VARCHAR2,
  X_INFORMATION8 in VARCHAR2,
  X_INFORMATION9 in VARCHAR2,
  X_INFORMATION10 in VARCHAR2,
  X_INFORMATION11 in VARCHAR2,
  X_INFORMATION12 in VARCHAR2
) is
  cursor c1 is select
      INFORMATION13,
      INFORMATION14,
      INFORMATION15,
      INFORMATION16,
      INFORMATION17,
      INFORMATION18,
      INFORMATION19,
      INFORMATION20,
      INFORMATION21,
      INFORMATION22,
      INFORMATION23,
      INFORMATION24,
      INFORMATION25,
      INFORMATION26,
      INFORMATION27,
      INFORMATION28,
      INFORMATION29,
      INFORMATION30,
      FORM_CANVAS_ID,
      TEMPLATE_CANVAS_ID,
      HEIGHT,
      VISIBLE,
      WIDTH,
      X_POSITION,
      Y_POSITION,
      INFORMATION_CATEGORY,
      INFORMATION1,
      INFORMATION2,
      INFORMATION3,
      INFORMATION4,
      INFORMATION5,
      INFORMATION6,
      INFORMATION7,
      INFORMATION8,
      INFORMATION9,
      INFORMATION10,
      INFORMATION11,
      INFORMATION12
    from HR_CANVAS_PROPERTIES
    where CANVAS_PROPERTY_ID = X_CANVAS_PROPERTY_ID
    for update of CANVAS_PROPERTY_ID nowait;
begin
  for tlinfo in c1 loop
      if (    ((tlinfo.INFORMATION13 = X_INFORMATION13)
               OR ((tlinfo.INFORMATION13 is null) AND (X_INFORMATION13 is null)))
          AND ((tlinfo.INFORMATION14 = X_INFORMATION14)
               OR ((tlinfo.INFORMATION14 is null) AND (X_INFORMATION14 is null)))
          AND ((tlinfo.INFORMATION15 = X_INFORMATION15)
               OR ((tlinfo.INFORMATION15 is null) AND (X_INFORMATION15 is null)))
          AND ((tlinfo.INFORMATION16 = X_INFORMATION16)
               OR ((tlinfo.INFORMATION16 is null) AND (X_INFORMATION16 is null)))
          AND ((tlinfo.INFORMATION17 = X_INFORMATION17)
               OR ((tlinfo.INFORMATION17 is null) AND (X_INFORMATION17 is null)))
          AND ((tlinfo.INFORMATION18 = X_INFORMATION18)
               OR ((tlinfo.INFORMATION18 is null) AND (X_INFORMATION18 is null)))
          AND ((tlinfo.INFORMATION19 = X_INFORMATION19)
               OR ((tlinfo.INFORMATION19 is null) AND (X_INFORMATION19 is null)))
          AND ((tlinfo.INFORMATION20 = X_INFORMATION20)
               OR ((tlinfo.INFORMATION20 is null) AND (X_INFORMATION20 is null)))
          AND ((tlinfo.INFORMATION21 = X_INFORMATION21)
               OR ((tlinfo.INFORMATION21 is null) AND (X_INFORMATION21 is null)))
          AND ((tlinfo.INFORMATION22 = X_INFORMATION22)
               OR ((tlinfo.INFORMATION22 is null) AND (X_INFORMATION22 is null)))
          AND ((tlinfo.INFORMATION23 = X_INFORMATION23)
               OR ((tlinfo.INFORMATION23 is null) AND (X_INFORMATION23 is null)))
          AND ((tlinfo.INFORMATION24 = X_INFORMATION24)
               OR ((tlinfo.INFORMATION24 is null) AND (X_INFORMATION24 is null)))
          AND ((tlinfo.INFORMATION25 = X_INFORMATION25)
               OR ((tlinfo.INFORMATION25 is null) AND (X_INFORMATION25 is null)))
          AND ((tlinfo.INFORMATION26 = X_INFORMATION26)
               OR ((tlinfo.INFORMATION26 is null) AND (X_INFORMATION26 is null)))
          AND ((tlinfo.INFORMATION27 = X_INFORMATION27)
               OR ((tlinfo.INFORMATION27 is null) AND (X_INFORMATION27 is null)))
          AND ((tlinfo.INFORMATION28 = X_INFORMATION28)
               OR ((tlinfo.INFORMATION28 is null) AND (X_INFORMATION28 is null)))
          AND ((tlinfo.INFORMATION29 = X_INFORMATION29)
               OR ((tlinfo.INFORMATION29 is null) AND (X_INFORMATION29 is null)))
          AND ((tlinfo.INFORMATION30 = X_INFORMATION30)
               OR ((tlinfo.INFORMATION30 is null) AND (X_INFORMATION30 is null)))
          AND ((tlinfo.FORM_CANVAS_ID = X_FORM_CANVAS_ID)
               OR ((tlinfo.FORM_CANVAS_ID is null) AND (X_FORM_CANVAS_ID is null)))
          AND ((tlinfo.TEMPLATE_CANVAS_ID = X_TEMPLATE_CANVAS_ID)
               OR ((tlinfo.TEMPLATE_CANVAS_ID is null) AND (X_TEMPLATE_CANVAS_ID is null)))
          AND ((tlinfo.HEIGHT = X_HEIGHT)
               OR ((tlinfo.HEIGHT is null) AND (X_HEIGHT is null)))
          AND ((tlinfo.VISIBLE = X_VISIBLE)
               OR ((tlinfo.VISIBLE is null) AND (X_VISIBLE is null)))
          AND ((tlinfo.WIDTH = X_WIDTH)
               OR ((tlinfo.WIDTH is null) AND (X_WIDTH is null)))
          AND ((tlinfo.X_POSITION = X_X_POSITION)
               OR ((tlinfo.X_POSITION is null) AND (X_X_POSITION is null)))
          AND ((tlinfo.Y_POSITION = X_Y_POSITION)
               OR ((tlinfo.Y_POSITION is null) AND (X_Y_POSITION is null)))
          AND ((tlinfo.INFORMATION_CATEGORY = X_INFORMATION_CATEGORY)
               OR ((tlinfo.INFORMATION_CATEGORY is null) AND (X_INFORMATION_CATEGORY is null)))
          AND ((tlinfo.INFORMATION1 = X_INFORMATION1)
               OR ((tlinfo.INFORMATION1 is null) AND (X_INFORMATION1 is null)))
          AND ((tlinfo.INFORMATION2 = X_INFORMATION2)
               OR ((tlinfo.INFORMATION2 is null) AND (X_INFORMATION2 is null)))
          AND ((tlinfo.INFORMATION3 = X_INFORMATION3)
               OR ((tlinfo.INFORMATION3 is null) AND (X_INFORMATION3 is null)))
          AND ((tlinfo.INFORMATION4 = X_INFORMATION4)
               OR ((tlinfo.INFORMATION4 is null) AND (X_INFORMATION4 is null)))
          AND ((tlinfo.INFORMATION5 = X_INFORMATION5)
               OR ((tlinfo.INFORMATION5 is null) AND (X_INFORMATION5 is null)))
          AND ((tlinfo.INFORMATION6 = X_INFORMATION6)
               OR ((tlinfo.INFORMATION6 is null) AND (X_INFORMATION6 is null)))
          AND ((tlinfo.INFORMATION7 = X_INFORMATION7)
               OR ((tlinfo.INFORMATION7 is null) AND (X_INFORMATION7 is null)))
          AND ((tlinfo.INFORMATION8 = X_INFORMATION8)
               OR ((tlinfo.INFORMATION8 is null) AND (X_INFORMATION8 is null)))
          AND ((tlinfo.INFORMATION9 = X_INFORMATION9)
               OR ((tlinfo.INFORMATION9 is null) AND (X_INFORMATION9 is null)))
          AND ((tlinfo.INFORMATION10 = X_INFORMATION10)
               OR ((tlinfo.INFORMATION10 is null) AND (X_INFORMATION10 is null)))
          AND ((tlinfo.INFORMATION11 = X_INFORMATION11)
               OR ((tlinfo.INFORMATION11 is null) AND (X_INFORMATION11 is null)))
          AND ((tlinfo.INFORMATION12 = X_INFORMATION12)
               OR ((tlinfo.INFORMATION12 is null) AND (X_INFORMATION12 is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
  end loop;
  return;
end LOCK_ROW;
--
-- -----------------------------------------------------------------------------
-- |------------------------------< update_row >-------------------------------|
-- -----------------------------------------------------------------------------
procedure UPDATE_ROW (
  X_CANVAS_PROPERTY_ID in NUMBER,
  X_INFORMATION13 in VARCHAR2,
  X_INFORMATION14 in VARCHAR2,
  X_INFORMATION15 in VARCHAR2,
  X_INFORMATION16 in VARCHAR2,
  X_INFORMATION17 in VARCHAR2,
  X_INFORMATION18 in VARCHAR2,
  X_INFORMATION19 in VARCHAR2,
  X_INFORMATION20 in VARCHAR2,
  X_INFORMATION21 in VARCHAR2,
  X_INFORMATION22 in VARCHAR2,
  X_INFORMATION23 in VARCHAR2,
  X_INFORMATION24 in VARCHAR2,
  X_INFORMATION25 in VARCHAR2,
  X_INFORMATION26 in VARCHAR2,
  X_INFORMATION27 in VARCHAR2,
  X_INFORMATION28 in VARCHAR2,
  X_INFORMATION29 in VARCHAR2,
  X_INFORMATION30 in VARCHAR2,
  X_FORM_CANVAS_ID in NUMBER,
  X_TEMPLATE_CANVAS_ID in NUMBER,
  X_HEIGHT in NUMBER,
  X_VISIBLE in NUMBER,
  X_WIDTH in NUMBER,
  X_X_POSITION in NUMBER,
  X_Y_POSITION in NUMBER,
  X_INFORMATION_CATEGORY in VARCHAR2,
  X_INFORMATION1 in VARCHAR2,
  X_INFORMATION2 in VARCHAR2,
  X_INFORMATION3 in VARCHAR2,
  X_INFORMATION4 in VARCHAR2,
  X_INFORMATION5 in VARCHAR2,
  X_INFORMATION6 in VARCHAR2,
  X_INFORMATION7 in VARCHAR2,
  X_INFORMATION8 in VARCHAR2,
  X_INFORMATION9 in VARCHAR2,
  X_INFORMATION10 in VARCHAR2,
  X_INFORMATION11 in VARCHAR2,
  X_INFORMATION12 in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update HR_CANVAS_PROPERTIES set
    INFORMATION13 = X_INFORMATION13,
    INFORMATION14 = X_INFORMATION14,
    INFORMATION15 = X_INFORMATION15,
    INFORMATION16 = X_INFORMATION16,
    INFORMATION17 = X_INFORMATION17,
    INFORMATION18 = X_INFORMATION18,
    INFORMATION19 = X_INFORMATION19,
    INFORMATION20 = X_INFORMATION20,
    INFORMATION21 = X_INFORMATION21,
    INFORMATION22 = X_INFORMATION22,
    INFORMATION23 = X_INFORMATION23,
    INFORMATION24 = X_INFORMATION24,
    INFORMATION25 = X_INFORMATION25,
    INFORMATION26 = X_INFORMATION26,
    INFORMATION27 = X_INFORMATION27,
    INFORMATION28 = X_INFORMATION28,
    INFORMATION29 = X_INFORMATION29,
    INFORMATION30 = X_INFORMATION30,
    FORM_CANVAS_ID = X_FORM_CANVAS_ID,
    TEMPLATE_CANVAS_ID = X_TEMPLATE_CANVAS_ID,
    HEIGHT = X_HEIGHT,
    VISIBLE = X_VISIBLE,
    WIDTH = X_WIDTH,
    X_POSITION = X_X_POSITION,
    Y_POSITION = X_Y_POSITION,
    INFORMATION_CATEGORY = X_INFORMATION_CATEGORY,
    INFORMATION1 = X_INFORMATION1,
    INFORMATION2 = X_INFORMATION2,
    INFORMATION3 = X_INFORMATION3,
    INFORMATION4 = X_INFORMATION4,
    INFORMATION5 = X_INFORMATION5,
    INFORMATION6 = X_INFORMATION6,
    INFORMATION7 = X_INFORMATION7,
    INFORMATION8 = X_INFORMATION8,
    INFORMATION9 = X_INFORMATION9,
    INFORMATION10 = X_INFORMATION10,
    INFORMATION11 = X_INFORMATION11,
    INFORMATION12 = X_INFORMATION12,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where CANVAS_PROPERTY_ID = X_CANVAS_PROPERTY_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;
--
-- -----------------------------------------------------------------------------
-- |------------------------------< delete_row >-------------------------------|
-- -----------------------------------------------------------------------------
procedure DELETE_ROW (
  X_CANVAS_PROPERTY_ID in NUMBER
) is
begin
  delete from HR_CANVAS_PROPERTIES
  where CANVAS_PROPERTY_ID = X_CANVAS_PROPERTY_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;
--
-- -----------------------------------------------------------------------------
-- |-------------------------------< load_row >--------------------------------|
-- -----------------------------------------------------------------------------
procedure LOAD_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_FORM_NAME in VARCHAR2,
  X_CANVAS_NAME in VARCHAR2,
  X_WINDOW_NAME in VARCHAR2,
  X_TEMPLATE_NAME in VARCHAR2,
  X_TERRITORY_SHORT_NAME in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_HEIGHT     in VARCHAR2,
  X_VISIBLE     in VARCHAR2,
  X_WIDTH     in VARCHAR2,
  X_X_POSITION  in VARCHAR2,
  X_Y_POSITION in VARCHAR2,
  X_INFORMATION_CATEGORY in VARCHAR2,
  X_INFORMATION1 in VARCHAR2,
  X_INFORMATION2 in VARCHAR2,
  X_INFORMATION3 in VARCHAR2,
  X_INFORMATION4 in VARCHAR2,
  X_INFORMATION5 in VARCHAR2,
  X_INFORMATION6 in VARCHAR2,
  X_INFORMATION7 in VARCHAR2,
  X_INFORMATION8 in VARCHAR2,
  X_INFORMATION9 in VARCHAR2,
  X_INFORMATION10 in VARCHAR2,
  X_INFORMATION11 in VARCHAR2,
  X_INFORMATION12 in VARCHAR2,
  X_INFORMATION13 in VARCHAR2,
  X_INFORMATION14 in VARCHAR2,
  X_INFORMATION15 in VARCHAR2,
  X_INFORMATION16 in VARCHAR2,
  X_INFORMATION17 in VARCHAR2,
  X_INFORMATION18 in VARCHAR2,
  X_INFORMATION19 in VARCHAR2,
  X_INFORMATION20 in VARCHAR2,
  X_INFORMATION21 in VARCHAR2,
  X_INFORMATION22 in VARCHAR2,
  X_INFORMATION23 in VARCHAR2,
  X_INFORMATION24 in VARCHAR2,
  X_INFORMATION25 in VARCHAR2,
  X_INFORMATION26 in VARCHAR2,
  X_INFORMATION27 in VARCHAR2,
  X_INFORMATION28 in VARCHAR2,
  X_INFORMATION29 in VARCHAR2,
  X_INFORMATION30 in VARCHAR2) is
  X_ROWID ROWID;
  X_CREATION_DATE DATE;
  X_CREATED_BY NUMBER;
  X_LAST_UPDATE_DATE DATE;
  X_LAST_UPDATED_BY NUMBER;
  X_LAST_UPDATE_LOGIN NUMBER;
  X_FORM_ID NUMBER;
  X_APPLICATION_ID NUMBER;
  X_FORM_CANVAS_ID NUMBER;
  X_FORM_WINDOW_ID NUMBER;
  X_TEMPLATE_CANVAS_ID NUMBER;
  X_CANVAS_PROPERTY_ID NUMBER;
begin
  OWNER_TO_WHO (
    X_OWNER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );
 select application_id
 into x_application_id
 from fnd_application
 where application_short_name = x_application_short_name;
 select form_id
 into x_form_id
 from fnd_form
 where form_name = x_form_name
 and application_id = x_application_id;

 select hfc.form_canvas_id, hfw.form_window_id
 into x_form_canvas_id,x_form_window_id
 from hr_form_canvases_b hfc
      , hr_form_windows_b hfw
 where hfc.canvas_name = x_canvas_name
 and hfw.form_window_id = hfc.form_window_id
 and hfw.application_id = x_application_id
 and hfw.form_id = x_form_id
 and hfw.window_name = x_window_name;

 IF ltrim(rtrim(x_template_name)) is not null then

 select htc.template_canvas_id
 into x_template_canvas_id
 from hr_template_canvases_b htc
      ,hr_template_windows_b htw
      , hr_form_templates hft
 where htc.form_canvas_id = x_form_canvas_id
 and htc.template_window_id = htw.template_window_id
 and htw.form_window_id = x_form_window_id
 and htw.form_template_id = hft.form_template_id
 and hft.application_id = x_application_id
 and hft.form_id = x_form_id
 and hft.template_name = x_template_name
 and (  (hft.legislation_code is null and x_territory_short_name is null)
     or (hft.legislation_code = x_territory_short_name) );
  x_form_canvas_id := null;
 ELSE
   x_template_canvas_id := null;
 END IF;

 begin
   select canvas_property_id
   into x_canvas_property_id
   from hr_canvas_properties
   where nvl(form_canvas_id,hr_api.g_number) =  nvl(x_form_canvas_id,hr_api.g_number)
   and nvl(template_canvas_id,hr_api.g_number) = nvl(x_template_canvas_id,hr_api.g_number);
 exception
   when no_data_found then
     select hr_canvas_properties_s.nextval
     into x_canvas_property_id
     from dual;
 end;

 begin

  UPDATE_COPIES (
    X_CANVAS_PROPERTY_ID,
    X_FORM_CANVAS_ID,
    X_TEMPLATE_CANVAS_ID,
    to_number(X_HEIGHT),
    to_number(X_VISIBLE),
    to_number(X_WIDTH),
    to_number(X_X_POSITION),
    to_number(X_Y_POSITION),
    X_INFORMATION_CATEGORY,
    X_INFORMATION1,
    X_INFORMATION2,
    X_INFORMATION3,
    X_INFORMATION4,
    X_INFORMATION5,
    X_INFORMATION6,
    X_INFORMATION7,
    X_INFORMATION8,
    X_INFORMATION9,
    X_INFORMATION10,
    X_INFORMATION11,
    X_INFORMATION12,
    X_INFORMATION13,
    X_INFORMATION14,
    X_INFORMATION15,
    X_INFORMATION16,
    X_INFORMATION17,
    X_INFORMATION18,
    X_INFORMATION19,
    X_INFORMATION20,
    X_INFORMATION21,
    X_INFORMATION22,
    X_INFORMATION23,
    X_INFORMATION24,
    X_INFORMATION25,
    X_INFORMATION26,
    X_INFORMATION27,
    X_INFORMATION28,
    X_INFORMATION29,
    X_INFORMATION30,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
    );

  UPDATE_ROW (
    X_CANVAS_PROPERTY_ID,
    X_INFORMATION13,
    X_INFORMATION14,
    X_INFORMATION15,
    X_INFORMATION16,
    X_INFORMATION17,
    X_INFORMATION18,
    X_INFORMATION19,
    X_INFORMATION20,
    X_INFORMATION21,
    X_INFORMATION22,
    X_INFORMATION23,
    X_INFORMATION24,
    X_INFORMATION25,
    X_INFORMATION26,
    X_INFORMATION27,
    X_INFORMATION28,
    X_INFORMATION29,
    X_INFORMATION30,
    X_FORM_CANVAS_ID,
    X_TEMPLATE_CANVAS_ID,
    to_number(X_HEIGHT),
    to_number(X_VISIBLE),
    to_number(X_WIDTH),
    to_number(X_X_POSITION),
    to_number(X_Y_POSITION),
    X_INFORMATION_CATEGORY,
    X_INFORMATION1,
    X_INFORMATION2,
    X_INFORMATION3,
    X_INFORMATION4,
    X_INFORMATION5,
    X_INFORMATION6,
    X_INFORMATION7,
    X_INFORMATION8,
    X_INFORMATION9,
    X_INFORMATION10,
    X_INFORMATION11,
    X_INFORMATION12,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
    );

 exception
   when no_data_found then
     INSERT_ROW (
        X_ROWID,
        X_CANVAS_PROPERTY_ID,
        X_INFORMATION13,
        X_INFORMATION14,
        X_INFORMATION15,
        X_INFORMATION16,
        X_INFORMATION17,
        X_INFORMATION18,
        X_INFORMATION19,
        X_INFORMATION20,
        X_INFORMATION21,
        X_INFORMATION22,
        X_INFORMATION23,
        X_INFORMATION24,
        X_INFORMATION25,
        X_INFORMATION26,
        X_INFORMATION27,
        X_INFORMATION28,
        X_INFORMATION29,
        X_INFORMATION30,
        X_FORM_CANVAS_ID,
        X_TEMPLATE_CANVAS_ID,
        to_number(X_HEIGHT),
        to_number(X_VISIBLE),
        to_number(X_WIDTH),
        to_number(X_X_POSITION),
        to_number(X_Y_POSITION),
        X_INFORMATION_CATEGORY,
        X_INFORMATION1,
        X_INFORMATION2,
        X_INFORMATION3,
        X_INFORMATION4,
        X_INFORMATION5,
        X_INFORMATION6,
        X_INFORMATION7,
        X_INFORMATION8,
        X_INFORMATION9,
        X_INFORMATION10,
        X_INFORMATION11,
        X_INFORMATION12,
        X_CREATION_DATE,
        X_CREATED_BY,
        X_LAST_UPDATE_DATE,
        X_LAST_UPDATED_BY,
        X_LAST_UPDATE_LOGIN);
 end;
end LOAD_ROW;
--
end HR_CANVAS_PROPERTIES_PKG;

/
