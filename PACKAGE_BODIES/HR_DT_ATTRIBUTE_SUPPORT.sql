--------------------------------------------------------
--  DDL for Package Body HR_DT_ATTRIBUTE_SUPPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DT_ATTRIBUTE_SUPPORT" as
/* $Header: dtattsup.pkb 120.0 2005/05/27 23:09:57 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |               Private Package Body Global Specifications                 |
-- ----------------------------------------------------------------------------
  g_package  varchar2(33) := '  hr_dt_attribute_support.';
--
  type l_varchar32767_tab is table of varchar2(32767)
    index by binary_integer;
  type l_varchar30_tab is table of varchar2(30)
    index by binary_integer;
  type l_boolean_tab is table of boolean
    index by binary_integer;
--
  g_parameter_name   l_varchar30_tab;
  g_old_value        l_varchar32767_tab; -- holds the 1st row values
  g_new_value        l_varchar32767_tab; -- holds the new datetrack values
  g_parameter_status l_boolean_tab;     -- determines the attribute status
  g_date_format      varchar2(10)   := 'dd/mm/yyyy';
  g_index            binary_integer;
  g_reset_index      boolean        := true;
-- ----------------------------------------------------------------------------
-- |-----------------------------< add_parameter >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private function adds the parameter and its properties to the pl/sql
--   data structures if the parameter is changing.
--
-- Pre-Requisities:
--   Should only be called for the row which is active of the effective date.
--
-- In Parameters:
--   p_parameter_name      --> the parameter name
--   p_new_value           --> as on the first row then specifies the new
--                             value to be used
--   p_current_value       --> specifies the current row value which is
--                             as of the effective date
--
-- Post Success:
--   If the parameter is being modified then it is added to the internal
--   pl/sql table datastructures and the value returned is the new value.
--   if the parameter is not being modified then the fuction returns the
--   current value passed in.
--
-- Post Failure:
--   None.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Private.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
function add_parameter
  (p_parameter_name  in varchar2
  ,p_new_value       in varchar2
  ,p_current_value   in varchar2) return varchar2 is
  --
  l_proc          varchar2(72)   :=  g_package||'add_parameter';
  l_current_value varchar2(32767);
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  -- check to see if the attribute is changing. we only add
  -- to the pl/sql table structures when values are changing.
  if nvl(p_new_value, hr_api.g_varchar2) =
     nvl(p_current_value, hr_api.g_varchar2) then
    -- the new value is the same as the current value therefore
    -- we cannot be updating the attribute. set the return value
    -- to the current value.
    l_current_value := p_current_value;
  else
    -- determine if we have to reset the index
    if g_reset_index then
      g_reset_index := false;
      g_index := 0;
    end if;
    -- as the attribute is changing add to the pl/sql table
    -- structures for further comparisons at the index position
    g_parameter_name(g_index)   := p_parameter_name;
    g_old_value(g_index)        := p_current_value;
    g_new_value(g_index)        := p_new_value;
    g_parameter_status(g_index) := true;
    l_current_value             := p_new_value;
    -- increment the index counter
    g_index := g_index + 1;
  end if;
  return(l_current_value);
  hr_utility.set_location(' Leaving:'|| l_proc, 10);
end add_parameter;
-- ----------------------------------------------------------------------------
-- |-------------------------< get_parameter_index >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private function returns the index position within the pl/sql table
--   structures for a given parameter name.
--
-- Pre-Requisities:
--   None.
--
-- In Parameters:
--   p_parameter_name  -> the parameter name
--
-- Post Success:
--   Index position is returned as a binary_integer.
--
-- Post Failure:
--   An error will be raised if the parameter name does not exist.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Private.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure is_parameter_changing
           (p_parameter_name in     varchar2
           ,p_changing          out nocopy boolean
           ,p_index             out nocopy binary_integer) is
  --
  l_proc       varchar2(72)   :=  g_package||'is_parameter_changing';
  l_index      binary_integer;
  l_found_name boolean        := false;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);
  -- ensure at least one element exists
  if g_index > 0 then
    -- determine index position of the parameter
    for i in 0..(g_index - 1) loop
      if g_parameter_name(i) = p_parameter_name then
        l_found_name := true;
        l_index := i;
        exit;
      end if;
    end loop;
  end if;
  --
  if l_found_name then
    -- a parameter has been found
    p_changing := true;
    p_index    := l_index;
  else
    -- parameter does not exist
    p_changing := false;
    p_index    := null;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 10);
end is_parameter_changing;
-- ----------------------------------------------------------------------------
-- |------------------------< get_parameter_char >----------------------------|
-- ----------------------------------------------------------------------------
function get_parameter_char
  (p_effective_date_row       in boolean  default false
  ,p_parameter_name  in varchar2
  ,p_new_value       in varchar2 default null
  ,p_current_value   in varchar2) return varchar2 is
  --
  l_proc           varchar2(72)   :=  g_package||'get_parameter_char';
  l_index          binary_integer := 0;
  l_new_value      varchar2(32767);
  l_current_value  varchar2(32767);
  l_changing       boolean;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);
  -- if on first row add the parameter
  if p_effective_date_row then
    -- determine if the user value is using a system default
    if p_new_value = hr_api.g_varchar2 then
      -- value is using a system default, set to the current row value
      l_new_value := p_current_value;
    else
      -- value is not using a system default
      l_new_value := p_new_value;
    end if;
    -- add the parameter to the pl/sql structures
    l_current_value := add_parameter
                         (p_parameter_name => p_parameter_name
                         ,p_new_value      => l_new_value
                         ,p_current_value  => p_current_value);
  else
    -- because we are replacing current values set the reset indicator
    -- to true
    g_reset_index := true;
    -- determine if the parameter is changing
    is_parameter_changing
           (p_parameter_name => p_parameter_name
           ,p_changing       => l_changing
           ,p_index          => l_index);
    --
    if l_changing then
      if nvl(p_current_value, hr_api.g_varchar2) =
         nvl(g_old_value(l_index), hr_api.g_varchar2) and
        g_parameter_status(l_index) then
        l_current_value := g_new_value(l_index);
      else
        g_parameter_status(l_index) := false;
        l_current_value := p_current_value;
      end if;
    else
      -- set the return value to the current value
      l_current_value := p_current_value;
    end if;
  end if;
  return(l_current_value);
  hr_utility.set_location(' Leaving:'|| l_proc, 10);
end get_parameter_char;
-- ----------------------------------------------------------------------------
-- |----------------------< get_parameter_number >----------------------------|
-- ----------------------------------------------------------------------------
function get_parameter_number
  (p_effective_date_row       in boolean  default false
  ,p_parameter_name  in varchar2
  ,p_new_value       in number   default null
  ,p_current_value   in number) return number is
  --
  l_proc          varchar2(72)   := g_package||'get_parameter_number';
  l_new_value     number         := p_new_value;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  if p_effective_date_row then
    -- determine if the user value is using a system default
    if l_new_value = hr_api.g_number then
      -- value is using a system default, set to the current row value
      l_new_value := p_current_value;
    end if;
  end if;
  --
  return(to_number(get_parameter_char
                     (p_effective_date_row       => p_effective_date_row
                     ,p_parameter_name  => p_parameter_name
                     ,p_new_value       => to_char(l_new_value)
                     ,p_current_value   => p_current_value)));
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 10);
end get_parameter_number;
-- ----------------------------------------------------------------------------
-- |-------------------------< get_parameter_date >---------------------------|
-- ----------------------------------------------------------------------------
function get_parameter_date
  (p_effective_date_row in boolean  default false
  ,p_parameter_name     in varchar2
  ,p_new_value          in date     default null
  ,p_current_value      in date) return date is
  --
  l_proc          varchar2(72)   := g_package||'get_parameter_date';
  l_new_value     date           := trunc(p_new_value);
  l_current_value varchar2(30)   := to_char(trunc(p_current_value), g_date_format);
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  if p_effective_date_row then
    -- determine if the user value is using a system default
    if trunc(p_new_value) = hr_api.g_date then
      -- value is using a system default, set to the current row value
      l_new_value := trunc(p_current_value);
    end if;
  end if;
  --
  return(to_date(get_parameter_char
                  (p_effective_date_row => p_effective_date_row
                  ,p_parameter_name  => p_parameter_name
                  ,p_new_value       => to_char(l_new_value, g_date_format)
                  ,p_current_value   => l_current_value), g_date_format));
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 10);
end get_parameter_date;
-- ----------------------------------------------------------------------------
-- |-----------------------< is_current_row_changing >------------------------|
-- ----------------------------------------------------------------------------
function is_current_row_changing return boolean is
  --
  l_proc  varchar2(72)   :=  g_package||'is_current_row_changing';
  l_index binary_integer;
  l_found boolean := false;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);
  -- only process if at least one element has been set
  if g_index > 0 then
    -- determine if at least one parameter change exists
    for l_index in 0..(g_index - 1) loop
      if g_parameter_status(l_index) then
        l_found := true;
        exit;
      end if;
    end loop;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 10);
  return(l_found);
end is_current_row_changing;
-- ----------------------------------------------------------------------------
-- |---------------------< reset_parameter_statuses >-------------------------|
-- ----------------------------------------------------------------------------
procedure reset_parameter_statuses is
  --
  l_proc  varchar2(72)   :=  g_package||'reset_parameter_statuses';
  l_index binary_integer;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  -- only process if at least one element has been set
  if g_index > 0 then
    for l_index in 0..(g_index - 1) loop
      g_parameter_status(l_index) := true;
    end loop;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 10);
end reset_parameter_statuses;
--
end hr_dt_attribute_support;

/
