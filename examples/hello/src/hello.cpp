//-----------------------------------------------------------------------------
// Copyright (c) 2017 Owner
//-----------------------------------------------------------------------------
#include <iostream>
#include "hello_set.hpp"
#include "hello_static.hpp"

int main() {  //lint !e970 NOLINT
  std::cout << getSetText() << std::endl;     //lint !e1963 !e1960 NOLINT
  std::cout << getStaticText() << std::endl;  //lint !e1963 !e1960 NOLINT
  return 0;
}
