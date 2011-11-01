/*
 *  indexing.c
 *  Sandbox
 *
 *  Created by Joshua Lewis on 11/3/10.
 *  Helper functions for linear matrix indices.
 *
 */

#include "indexing.h"


int utidx(int row, int col) { // Upper triangular index
  return col * (col + 1) / 2 + row;
}


int utndidx(int row, int col) { // Upper triangular index, no diagonal
  return col * (col - 1) / 2 + row;
}