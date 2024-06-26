/****************************************************************************
 * Copyright (C) 2022 by Alessio Zattoni                                    *
 *                                                                          *
 * This file is part of CrossCorrelation.                                   *
 *                                                                          *
 *   CrossCorrelation is free software: you can redistribute it and/or      *
 *   modify it under the terms of the GNU Lesser General Public License as  *
 *   published by the Free Software Foundation, either version 3 of the     * 
 *   License, or (at your option) any later version.                        * 
 *                                                                          *
 *   CrossCorrelation is distributed in the hope that it will be            *
 *   useful, but WITHOUT ANY WARRANTY; without even the implied warranty of *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          *
 *   GNU Lesser General Public License for more details.                    *
 *                                                                          *
 *   You should have received a copy of the GNU Lesser General Public       *
 *   License along with Box.  If not, see <http://www.gnu.org/licenses/>.   *
 ****************************************************************************/



/**
 * @file    standard_formats_benchmark.cu
 * @author  Alessio Zattoni
 * @date 
 * @brief   Questo file contiene il benchmark del progetto di cross-correlazione
 *          eseguito con formati di matrici d'interesse per il progetto
 *
 * ...
 */



#include "benchmark.hpp"

#define KERNEL_SIZE_MIN 3
#define KERNEL_SIZE_MAX 11
#define BLOCK_DIM_MIN   8
#define DEV             0
#define ITERATIONS      5

extern const std::vector<format::standardFormat> form;


int main()
{
    cudaSetDevice(DEV);
    cudaDeviceProp deviceProp;
    cudaGetDeviceProperties(&deviceProp, DEV);
    
    std::size_t max_thread_per_block = std::sqrt(deviceProp.maxThreadsPerBlock);

    // Benchmark di formati di matrice interessanti per il progetto
    std::string title("\n=============================================================================");
    for (auto format : form) {
        std::size_t rows = format.getRows();
        std::size_t cols = format.getCols();
        for (size_t block_dim_x_y = BLOCK_DIM_MIN; block_dim_x_y <= rows && block_dim_x_y <= cols && block_dim_x_y <= max_thread_per_block; block_dim_x_y *= 2) {
            for (size_t kernel_size = KERNEL_SIZE_MIN; kernel_size <= rows && kernel_size <= cols && kernel_size <= KERNEL_SIZE_MAX; kernel_size += 2) {
                benchmark<uint8_t>(rows, cols, kernel_size, block_dim_x_y, block_dim_x_y, "results/standard_formats", ITERATIONS);
                std::cout << title + "\n\t\tEND\n" + std::string(title.size(), '=') +  "\n\n";
            }
        }
    }
    
    exit(EXIT_SUCCESS);
}