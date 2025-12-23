#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

void test_calloc() {
    printf("\n=== Testing calloc ===\n");
    
    // Test 1: Basic calloc functionality
    printf("Test 1: Basic calloc - allocate 10 integers\n");
    int *arr = (int*)calloc(10, sizeof(int));
    if(arr == 0) {
        printf("  FAILED: calloc returned NULL\n");
        return;
    }
    
    // Check if all bytes are initialized to zero
    int all_zero = 1;
    for(int i = 0; i < 10; i++) {
        if(arr[i] != 0) {
            all_zero = 0;
            break;
        }
    }
    if(all_zero) {
        printf("  PASSED: All elements initialized to zero\n");
    } else {
        printf("  FAILED: Elements not initialized to zero\n");
    }
    
    // Test 2: Write and read data
    printf("Test 2: Write and read data\n");
    for(int i = 0; i < 10; i++) {
        arr[i] = i * 2;
    }
    
    int write_read_ok = 1;
    for(int i = 0; i < 10; i++) {
        if(arr[i] != i * 2) {
            write_read_ok = 0;
            break;
        }
    }
    if(write_read_ok) {
        printf("  PASSED: Data written and read correctly\n");
    } else {
        printf("  FAILED: Data corruption detected\n");
    }
    
    free(arr);
    
    // Test 3: calloc with different sizes
    printf("Test 3: calloc with 100 chars\n");
    char *str = (char*)calloc(100, sizeof(char));
    if(str == 0) {
        printf("  FAILED: calloc returned NULL\n");
        return;
    }
    
    all_zero = 1;
    for(int i = 0; i < 100; i++) {
        if(str[i] != 0) {
            all_zero = 0;
            break;
        }
    }
    if(all_zero) {
        printf("  PASSED: All 100 bytes initialized to zero\n");
    } else {
        printf("  FAILED: Bytes not initialized to zero\n");
    }
    
    free(str);
    printf("calloc tests completed!\n");
}

void test_realloc() {
    printf("\n=== Testing realloc ===\n");
    
    // Test 1: realloc with NULL pointer (should behave like malloc)
    printf("Test 1: realloc(NULL, 50) - should act like malloc\n");
    int *ptr = (int*)realloc(0, 50 * sizeof(int));
    if(ptr == 0) {
        printf("  FAILED: realloc returned NULL\n");
        return;
    }
    printf("  PASSED: Memory allocated\n");
    
    // Write some data
    for(int i = 0; i < 50; i++) {
        ptr[i] = i;
    }
    
    // Test 2: Expand allocation
    printf("Test 2: Expand from 50 to 100 integers\n");
    int *new_ptr = (int*)realloc(ptr, 100 * sizeof(int));
    if(new_ptr == 0) {
        printf("  FAILED: realloc returned NULL\n");
        free(ptr);
        return;
    }
    
    // Check if old data is preserved
    int data_preserved = 1;
    for(int i = 0; i < 50; i++) {
        if(new_ptr[i] != i) {
            data_preserved = 0;
            break;
        }
    }
    if(data_preserved) {
        printf("  PASSED: Old data preserved after expansion\n");
    } else {
        printf("  FAILED: Data lost during expansion\n");
    }
    
    ptr = new_ptr;
    
    // Test 3: Shrink allocation
    printf("Test 3: Shrink from 100 to 25 integers\n");
    new_ptr = (int*)realloc(ptr, 25 * sizeof(int));
    if(new_ptr == 0) {
        printf("  FAILED: realloc returned NULL\n");
        free(ptr);
        return;
    }
    
    // Check if data is still preserved (first 25 elements)
    data_preserved = 1;
    for(int i = 0; i < 25; i++) {
        if(new_ptr[i] != i) {
            data_preserved = 0;
            break;
        }
    }
    if(data_preserved) {
        printf("  PASSED: Data preserved after shrinking\n");
    } else {
        printf("  FAILED: Data lost during shrinking\n");
    }
    
    ptr = new_ptr;
    
    // Test 4: realloc with nbytes = 0 (should free and return NULL)
    printf("Test 4: realloc(ptr, 0) - should act like free\n");
    void *result = realloc(ptr, 0);
    if(result == 0) {
        printf("  PASSED: Returned NULL and freed memory\n");
    } else {
        printf("  FAILED: Did not return NULL\n");
        free(result);
    }
    
    printf("realloc tests completed!\n");
}

void test_combined() {
    printf("\n=== Testing Combined Scenarios ===\n");
    
    // Test 1: Use calloc, then realloc
    printf("Test 1: calloc then realloc\n");
    int *arr = (int*)calloc(5, sizeof(int));
    if(arr == 0) {
        printf("  FAILED: calloc returned NULL\n");
        return;
    }
    
    // Verify zero initialization
    int all_zero = 1;
    for(int i = 0; i < 5; i++) {
        if(arr[i] != 0) {
            all_zero = 0;
        }
    }
    
    // Write some data
    for(int i = 0; i < 5; i++) {
        arr[i] = 100 + i;
    }
    
    // Realloc to larger size
    arr = (int*)realloc(arr, 10 * sizeof(int));
    if(arr == 0) {
        printf("  FAILED: realloc returned NULL\n");
        return;
    }
    
    // Check if original data preserved
    int preserved = 1;
    for(int i = 0; i < 5; i++) {
        if(arr[i] != 100 + i) {
            preserved = 0;
        }
    }
    
    if(all_zero && preserved) {
        printf("  PASSED: calloc initialized to zero, realloc preserved data\n");
    } else {
        printf("  FAILED: Data issue detected\n");
    }
    
    free(arr);
    
    // Test 2: Multiple allocations
    printf("Test 2: Multiple allocations and deallocations\n");
    void *p1 = calloc(10, 1);
    void *p2 = malloc(20);
    void *p3 = calloc(5, 4);
    
    if(p1 && p2 && p3) {
        printf("  PASSED: Multiple allocations succeeded\n");
        free(p1);
        free(p2);
        free(p3);
    } else {
        printf("  FAILED: Some allocations failed\n");
        if(p1) free(p1);
        if(p2) free(p2);
        if(p3) free(p3);
    }
    
    printf("Combined tests completed!\n");
}

void test_edge_cases() {
    printf("\n=== Testing Edge Cases ===\n");
    
    // Test 1: Large allocation
    printf("Test 1: Large allocation with calloc\n");
    char *large = (char*)calloc(5000, sizeof(char));
    if(large) {
        printf("  PASSED: Large allocation succeeded\n");
        free(large);
    } else {
        printf("  WARNING: Large allocation failed (may be expected)\n");
    }
    
    // Test 2: Zero elements in calloc
    printf("Test 2: calloc(0, 10)\n");
    void *zero_num = calloc(0, 10);
    if(zero_num) {
        printf("  INFO: Allocated memory for 0 elements\n");
        free(zero_num);
    } else {
        printf("  INFO: Returned NULL for 0 elements\n");
    }
    
    // Test 3: Zero size in calloc
    printf("Test 3: calloc(10, 0)\n");
    void *zero_size = calloc(10, 0);
    if(zero_size) {
        printf("  INFO: Allocated memory for 0-byte elements\n");
        free(zero_size);
    } else {
        printf("  INFO: Returned NULL for 0-byte elements\n");
    }
    
    printf("Edge case tests completed!\n");
}

int main(void) {
    printf("====================================\n");
    printf("Memory Allocation Test Suite\n");
    printf("Testing realloc() and calloc()\n");
    printf("====================================\n");
    
    test_calloc();
    test_realloc();
    test_combined();
    test_edge_cases();
    
    printf("\n====================================\n");
    printf("All tests completed!\n");
    printf("====================================\n");
    
    exit(0);
}
